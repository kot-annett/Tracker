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
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("couldn't get app delegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            preconditionFailure("Failed to initialize TrackerStore: \(error)")
        }
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
        guard let trackerCoreData = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else { return nil }
        let newTracker = TrackerCoreData(entity: trackerCoreData, insertInto: context)
        newTracker.id = tracker.id
        newTracker.name = tracker.name
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule
        newTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        
        return newTracker
    }
    
    func fetchTracker() throws -> [Tracker] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            let trackers = trackerCoreDataArray.map { trackerCoreData in
                return Tracker(
                    id: trackerCoreData.id ?? UUID(),
                    name: trackerCoreData.name ?? "",
                    color: uiColorMarshalling.color(from: trackerCoreData.color ?? ""),
                    emoji: trackerCoreData.emoji ?? "",
                    schedule: trackerCoreData.schedule ?? "")
            }
            return trackers
        } catch {
            throw StoreError.decodeError
        }
    }
    
    func fetchTrackerCoreData() throws -> [TrackerCoreData] {
        do {
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            return trackerCoreDataArray
        } catch {
            throw StoreError.decodeError
        }
    }
 
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
