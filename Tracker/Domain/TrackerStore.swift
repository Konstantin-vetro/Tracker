//
//  TrackerStore.swift
//  Tracker
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColor
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidShedule
}

final class TrackerStore: NSObject {
    private let uiCollorMarshalling = UIColorMarshalling()
    private let weekdaysMarshalling = WeekDayMarshalling()
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()

    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultController.fetchedObjects,
            let trackers = try? objects.map({ try self.makeTracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func makeTracker(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackersCoreData.trackerID else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        
        guard let name = trackersCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        
        guard let color = trackersCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        
        guard let emojie = trackersCoreData.emojie else {
            throw TrackerStoreError.decodingErrorInvalidEmojies
        }
        
        guard let shedule = trackersCoreData.shedule else {
            throw TrackerStoreError.decodingErrorInvalidShedule
        }
        
        return Tracker(
            id: id,
            name: name,
            color: uiCollorMarshalling.color(from: color),
            emojie: emojie,
            shedule: weekdaysMarshalling.makeWeekDayArrayFromString(shedule: shedule)
        )
    }
    
    // MARK: - CRUD
    func createTracker(from tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiCollorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojie = tracker.emojie
        trackerCoreData.shedule = weekdaysMarshalling.makeStringFromArray(tracker.shedule ?? [])
        return trackerCoreData
    }
    
    func deleteTracker(with id: UUID) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id.uuidString)
        let trackers = try context.fetch(request)
        if let trackerDelete = trackers.first {
            context.delete(trackerDelete)
            do {
                try context.save()
            } catch {
                print("Failed to save context after deleting tracker: \(error)")
                throw error
            }
        }
    }
}
