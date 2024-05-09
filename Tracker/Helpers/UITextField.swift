//
//  UITextField.swift
//  Tracker
//
//  Created by Anna on 15.04.2024.
//

import Foundation
import UIKit

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            if let maxLength = objc_getAssociatedObject(self, &maxLengthKey) as? Int {
                return maxLength
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &maxLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(limitLength), for: .editingChanged)
        }
    }

    @objc func limitLength() {
        if let text = self.text, text.count > maxLength {
            self.text = String(text.prefix(maxLength))
        }
    }
}

private var maxLengthKey: UInt8 = 0

