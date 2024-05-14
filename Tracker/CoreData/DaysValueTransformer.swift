//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Anna on 09.05.2024.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let days = value as? [WeekDay] else { return nil }
//        return try? JSONEncoder().encode.rawValue(days)
//    }
//
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? NSData else { return nil }
//        return try? JSONDecoder().decode.rawValue([WeekDay].self, from: data as Data)
//    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))
        )
    }
}
