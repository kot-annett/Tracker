//
//  Constant.swift
//  Tracker
//
//  Created by Anna on 14.04.2024.
//

import Foundation

enum Constant {
    static let emojies: [String] = [
    "😃", "🥰", "🤩", "🥳", "🤯", "💯",
    "😈", "😻", "🙌", "👀", "💃", "👨‍👩‍👧‍👦",
    "🐶", "🪴", "🍎", "🥑", "🍷", "🛼",
    "🧘‍♀️", "🎹", "✈️", "🏝️", "⏰", "❤️"
    ]
    
    //ScheduleViewController
    static let scheduleTableViewTitles = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
}

extension Constant {
    static func randomEmoji() -> String {
        return emojies.randomElement() ?? "❤️"
    }
}





