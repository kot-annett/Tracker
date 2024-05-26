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
    private var categories: [TrackerCategory] = []
    public weak var delegate: TrackerCategoryStoreDelegate?
    
    private let trackerStore = TrackerStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("couldn't get app delegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            preconditionFailure("Failed to initialize TrackerCategoryStore: \(error)")
        }
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
    
    var isEmpty: Bool {
        do {
            let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            let count  = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    func addNewCategory( _ categoryName: TrackerCategory) throws {
        guard let trackerCategoryCoreData = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
        
        // Проверка на уникальность
        if try context.fetch(TrackerCategoryCoreData.fetchRequest()).contains(where: { $0.title == categoryName.title }) {
            print("Category already exists: \(categoryName.title)")
            return
        }
        
        let newCategory = TrackerCategoryCoreData(entity: trackerCategoryCoreData, insertInto: context)
        newCategory.title = categoryName.title
        newCategory.trackers = []
//        newCategory.trackers = NSSet(array: [])
        do {
            try context.save()
            print("Context saved successfully")
        } catch {
            context.rollback()
            throw StoreError.decodeError
        }
    }
 
    func fetchCategories() throws -> [TrackerCategoryCoreData] {
        do {
            let categories = try context.fetch(NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData"))
            print("Fetched from CoreData: \(categories.map { $0.title ?? "nil" })")
            return categories
        } catch {
            throw StoreError.decodeError
        }
//        do {
//            return try context.fetch(NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData"))
//        } catch {
//            throw StoreError.decodeError
//        }
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
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func addNewTrackerToCategory(_ tracker: Tracker, to trackerCategory: String) throws {
        let newTrackerCoreData = try trackerStore.fetchTrackerCoreData()
        guard let currentCategory = category(with: trackerCategory) else { return }
        var currentTrackers = currentCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        if let index = newTrackerCoreData.firstIndex(where: {$0.id == tracker.id}) {
            currentTrackers.append(newTrackerCoreData[index])
        }
        currentCategory.trackers = NSSet(array: currentTrackers)
        do {
            try context.save()
        } catch {
            throw StoreError.decodeError
        }
    }
    
    func category(with categoryName: String) -> TrackerCategoryCoreData? {
        return try? fetchCategories().filter({$0.title == categoryName}).first ?? nil
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        do {
            try context.save()
        } catch {
            throw StoreError.decodeError
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
