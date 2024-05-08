//
//  Constant.swift
//  Tracker
//
//  Created by Anna on 14.04.2024.
//

import Foundation
import UIKit

enum Constant {
    static let emojies: [String] = [
    "🏝️", "🥰", "🤩", "🥳", "✈️", "💯",
    "😈", "😻", "❤️", "👀", "💃", "👨‍👩‍👧‍👦",
    "🐶", "🪴", "🍎", "🥑", "🍷", "🛼",
    ]
    
    //ScheduleViewController
    static let scheduleTableViewTitles = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    static let colorSelection = (1...18).map({ UIColor(named: String($0)) })
    
    static let collectionViewTitles = ["Emoji", "Цвет"]
}

extension Constant {
    static func randomEmoji() -> String {
        return emojies.randomElement() ?? "❤️"
    }
}





