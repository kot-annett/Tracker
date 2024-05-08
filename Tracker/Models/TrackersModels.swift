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
//    let schedule: [WeekDay]
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [String]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let trackerID: UUID
    let date: Date
}

enum WeekDay: Int, CaseIterable {
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Sunday = 0
    
    var stringValue: String {
        switch self {
            case .Monday: return "Пн"
            case .Tuesday: return "Вт"
            case .Wednesday: return "Ср"
            case .Thursday: return "Чт"
            case .Friday: return "Пт"
            case .Saturday: return "Сб"
            case .Sunday: return "Вс"
        }
    }
}

enum TrackerType {
    case habit
    case event
}
