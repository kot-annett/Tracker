//
//  TrackersModels.swift
//  Tracker
//
//  Created by Anna on 07.04.2024.
//

import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [String]
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: String) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = [schedule]
    }
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord {
    let trackerID: UUID
    let date: Date
    
    init(trackerID: UUID, date: Date) {
        self.trackerID = trackerID
        self.date = date
    }
}
