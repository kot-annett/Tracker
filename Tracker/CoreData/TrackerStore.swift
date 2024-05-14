//
//  TrackerStore.swift
//  Tracker
//
//  Created by Anna on 09.05.2024.
//

import CoreData
import UIKit

enum StoreError: Error {
    case decodeError
}

final class TrackerStore: NSObject {
    public weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
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
    
    func addTracker(from tracker: Tracker) -> TrackerCoreData? {
//        let trackerCoreData = TrackerCoreData(context: context)
        guard let trackerCoreData = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else { return nil }
        let newTracker = TrackerCoreData(entity: trackerCoreData, insertInto: context)
        newTracker.id = tracker.id
        newTracker.name = tracker.name
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule
        newTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        
        return newTracker
    }
    
    func fetchTracker() -> [Tracker] {
        //        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackerCoreDataArray = try! context.fetch(fetchRequest)
        let trackers = trackerCoreDataArray.map { trackerCoreData in
            return Tracker(
                id: trackerCoreData.id ?? UUID(),
                name: trackerCoreData.name ?? "",
                color: uiColorMarshalling.color(from: trackerCoreData.color ?? ""),
                emoji: trackerCoreData.emoji ?? "",
                schedule: trackerCoreData.schedule ?? "")
        }
        return trackers
    }
    
    func fetchTrackerCoreData() -> [TrackerCoreData] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackerCoreDataArray = try! context.fetch(fetchRequest)
        return trackerCoreDataArray
    }
    
//    func deleteTracker(tracker: Tracker) {
//        // Получаем объект TrackerCoreData
//        let tracker = fetchTrackerCoreData()
//        
//        // Удаляем объект из контекста и сохраняем контекст
//        if let index = tracker.firstIndex(where: {$0.id == tracker.id}) {
//            context.delete(tracker[index])
//        }
//    }
    
    func changeTrackers(from trackersCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackersCoreData.id,
            let name = trackersCoreData.name,
            let color = trackersCoreData.color,
            let emoji = trackersCoreData.emoji
        else { return nil }
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: color),
            emoji: emoji,
            schedule: trackersCoreData.schedule ?? "")
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}

// ???
//    func changeTracker(_ newTracker: Tracker, _ categoryName: String) throws {
//        guard let tracker = fetchedResultsController.fetchedObjects?.first(where: {
//            $0.id == newTracker.id
//        }) else {
//            print("Tracker with id \(newTracker.id) not found.")
//            return
//        }
//        tracker.name = newTracker.name
//        tracker.color = uiColorMarshalling.hexString(from: newTracker.color)
//        tracker.schedule = newTracker.schedule
//        tracker.emoji = newTracker.emoji
//        tracker.category = TrackerCategoryStore().category(categoryName)
//
//        if let category = try TrackerCategoryStore(context: context).category(categoryName) {
//                tracker.category = category
//            } else {
//                print("Category with name \(categoryName) not found.")
//            }
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save context: \(error)")
//        }
//    }
