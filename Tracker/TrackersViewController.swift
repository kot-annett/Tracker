//
//  ViewController.swift
//  Tracker
//
//  Created by Anna on 05.04.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    private let searchBar: UISearchController = {
        let searchBar = UISearchController()
        return searchBar
    }()
    
    private let placeholderImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "star")
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
    }
    
    @objc private func addTrackerButtonTapped() {
        let navigationController = UINavigationController(rootViewController: NewTrackerViewController())
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [collectionView,
         placeholderImageView,
         placeholderLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
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
        navigationItem.title = "Трекеры"
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerButtonTapped))
        navigationItem.leftBarButtonItem = addButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = searchBar
        
    }
    
    private func updateUI() {
        if categories.isEmpty {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            collectionView.isHidden = false
            
            collectionView.reloadData()
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.flatMap { $0.trackers }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        let category = categories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        cell.configure(with: tracker)
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        print("Выбран трекер: \(tracker.name)")
        
        let trackerRecord = TrackerRecord(trackerID: tracker.id, date: Date())
        addTrackerRecord(trackerRecord)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        
        removeTrackerRecord(with: tracker.id)
    }
}

extension TrackersViewController {
    func addTracker(_ tracker: Tracker, to categoryIndex: Int) {
        var updatedCategories = categories
        
        if categoryIndex < updatedCategories.count {
            updatedCategories[categoryIndex].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: "Новая категория", trackers: [tracker])
            updatedCategories.append(newCategory)
        }
        
        categories = updatedCategories
        
        updateUI()
    }
    
    // Метод для добавления записи о выполнении трекера в массив completedTrackers
    func addTrackerRecord(_ trackerRecord: TrackerRecord) {
        completedTrackers.append(trackerRecord)
    }
    
    // Метод для удаления записи о выполнении трекера из массива completedTrackers
    func removeTrackerRecord(with trackerID: UUID) {
        completedTrackers.removeAll { $0.trackerID == trackerID }
    }
}

