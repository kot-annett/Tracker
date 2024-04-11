//
//  TabBarController.swift
//  Tracker
//
//  Created by Anna on 06.04.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        let statisticVC = UINavigationController(rootViewController: StatisticViewController())
        
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        viewControllers = [
        trackersVC,
        statisticVC
        ]
    }
}
