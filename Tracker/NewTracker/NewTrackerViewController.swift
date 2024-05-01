//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Anna on 10.04.2024.
//

import Foundation
import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func setDateForNewTracker() -> String
    func didCreateNewTracker(_ tracker: Tracker)
}

final class NewTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Создание трекера"
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        habitButton.addTarget(
            self,
            action: #selector(habitButtonTapped),
            for: .touchUpInside
        )
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        eventButton.addTarget(
            self,
            action: #selector(eventButtonTapped),
            for: .touchUpInside
        )
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 20),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = delegate
        navigationController?.pushViewController(newHabitViewController, animated: true)
        print("Привычка button tapped")
    }
    
    @objc private func eventButtonTapped() {
        navigationController?.pushViewController(NewEventViewController(), animated: true)
        print("Нерегулярное событие button tapped")
    }
}
