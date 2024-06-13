//
//  Colors.swift
//  Tracker
//
//  Created by Anna on 04.06.2024.
//

import UIKit

final class Colors {
    let viewBackgroundColor = UIColor.systemBackground
    
    var navigationBarTintColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.ypWhite : UIColor.ypBlack
    }
    
    let ypBlack = UIColor(named: "ypBlack")
    let ypWhite = UIColor(named: "ypWhite")
}
