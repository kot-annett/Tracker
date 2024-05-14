//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Anna on 09.05.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
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
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerID, ascending: true)
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
    
    var completedTrackers: Set<TrackerRecord> {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let completedTrackers = try? objects.map({ try completedTracker(from: $0)})
        else { return [] }
        return Set(completedTrackers)
    }
    
    private func completedTracker(from data: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = data.trackerID,
            let date = data.date
        else {
            throw StoreError.decodeError
        }
        return TrackerRecord(
            trackerID: id,
            date: date
        )
    }
    
    func addNewRecord(from trackerRecord: TrackerRecord) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else { return }
        let newRecord = TrackerRecordCoreData(entity: entity, insertInto: context)
        newRecord.trackerID = trackerRecord.trackerID
        newRecord.date = trackerRecord.date
        try! context.save()
    }
    
    func deleteTrackerRecord(trackerRecord: TrackerRecord) {
        guard let record = fetchedResultsController.fetchedObjects?.first(where: {
            $0.trackerID == trackerRecord.trackerID && $0.date == trackerRecord.date
        }) else { return }
        context.delete(record)
        try! context.save()
    }
    
//    func deleteAllRecordFor(tracker: Tracker) {
//        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
//        do {
//            let records = try context.fetch(fetchRequest)
//            for recordToDelete in records {
//                context.delete(recordToDelete)
//            }
//            try context.save()
//        } catch {
//            print("Error deleting records: \(error.localizedDescription)")
//        }
//    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordCoreDataArray = try! context.fetch(fetchRequest)
        let trackerRecords = trackerRecordCoreDataArray.map { trackerRecordCoreData in
            return TrackerRecord(
                trackerID: trackerRecordCoreData.trackerID ?? UUID(),
                date: trackerRecordCoreData.date ?? Date()
            )
        }
        return Set(trackerRecords)
    }
}

