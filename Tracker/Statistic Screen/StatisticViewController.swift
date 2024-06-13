//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Anna on 06.04.2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    private var trackers: [Tracker] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private let trackerRecordStore = TrackerRecordStore()
    private let statView = CustomStatisticView(title: "0", subtitle: "Трекеров завершено")
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let placeholderImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "statisticHolder")
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerRecordStore.delegate = self
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statView.frame = CGRect(x: 16, y: self.view.frame.midY - 45, width: self.view.frame.width - 32, height: 90)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [placeholderImageView, placeholderLabel, statView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        statView.frame = CGRect(x: 16, y: self.view.frame.midY, width: self.view.frame.width - 32, height: 90)
        statView.setupUI()
        
        NSLayoutConstraint.activate([
            statView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statView.heightAnchor.constraint(equalToConstant: 90),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 10),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Статистика"
    }
    
    private func updateUI() {
        if completedTrackers.isEmpty {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            statView.isHidden = true
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            statView.isHidden = false
        }
    }
    
    private func updateStatistic() {
        completedTrackers = trackerRecordStore.completedTrackers
        let quantity = completedTrackers.count
        statView.configValue(value: quantity)
        updateUI()
    }
}

extension StatisticViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        updateStatistic()
    }
}
