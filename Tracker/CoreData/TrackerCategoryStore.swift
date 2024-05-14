//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Anna on 09.05.2024.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    
    public weak var delegate: TrackerCategoryStoreDelegate?
    
    private let trackerStore = TrackerStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("couldn't get app delegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }

    func addNewCategory( _ categoryName: TrackerCategory) {
        //        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        guard let trackerCategoryCoreData = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
        let newCategory = TrackerCategoryCoreData(entity: trackerCategoryCoreData, insertInto: context)
        newCategory.title = categoryName.title
        newCategory.trackers = NSSet(array: [])
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        return try! context.fetch(NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData"))
    }
    
    func updateTrackerCategory(_ category: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let newTitle = category.title else { return nil }
        guard let trackers = category.trackers else { return nil }
        
        return TrackerCategory(title: newTitle, trackers: trackers.compactMap { coreDataTracker -> Tracker? in
            if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                return trackerStore.changeTrackers(from: coreDataTracker)
            }
            return nil
        })
    }
    
    func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        guard let trackerCoreData = trackerStore.addTracker(from: tracker) else { return }
        guard let currentCategory = category(with: titleCategory) else { return }
        var currentTrackers = currentCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        currentTrackers.append(trackerCoreData)
        currentCategory.trackers = NSSet(array: currentTrackers)
        try! context.save()
    }
    
    func addNewTrackerToCategory(_ tracker: Tracker, to trackerCategory: String) {
//        let newTrackerCoreData = trackerStore.addTracker(from: tracker)
        let newTrackerCoreData = trackerStore.fetchTrackerCoreData()
//        guard let category = fetchedResultsController.fetchedObjects?.first(where: { $0.title == trackerCategory }) else {}
        guard let currentCategory = category(with: trackerCategory) else { return }
        var currentTrackers = currentCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        if let index = newTrackerCoreData.firstIndex(where: {$0.id == tracker.id}) {
            currentTrackers.append(newTrackerCoreData[index])
        }
        currentCategory.trackers = NSSet(array: currentTrackers)
        try! context.save()
    }
    
    private func category(with categoryName: String) -> TrackerCategoryCoreData? {
        return fetchCategories().filter({$0.title == categoryName}).first ?? nil
    }
    
//    func category(_ categoryName: String) -> TrackerCategoryCoreData? {
//        return fetchedResultsController.fetchedObjects?.first {
//            $0.title == categoryName
//        }
//    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
        context.delete(category)
        do {
            try context.save()
        } catch {
            print("Failed to delete tracker category: \(error)")
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
