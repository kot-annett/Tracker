//
//  ViewController.swift
//  Tracker
//
//  Created by Anna on 05.04.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()
    
    private var trackers = [Tracker]()
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var originalCategories: [UUID: String] = [:]
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter = .all
    private let colors = Colors()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.reuseIdentifier
        )
        return collectionView
    }()
    
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
    
    private let placeholderImageFilter: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "filterHolder")
        return image
    }()
    
    private let placeholderLabelFilter: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Filters", comment: "Title for the filter button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blueBack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        syncData()
        updateUI()
        loadTrackersAndCategories()
        fetchRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    @objc private func addTrackerButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let newTrackerViewController = NewTrackerViewController()
        newTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filteredTrackers()
        applyFilter()
        updateUI()
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        filterViewController.selectedFilter = currentFilter
        let filterNavController = UINavigationController(rootViewController: filterViewController)
        self.present(filterNavController, animated: true)
    }
    
    private func loadTrackersAndCategories() {
        do {
            let trackerCategoriesCoreData = try trackerCategoryStore.fetchCategories()
            var trackerCategories = trackerCategoriesCoreData.compactMap { trackerCategoryStore.updateTrackerCategory($0) }
            
            if let pinnedIndex = trackerCategories.firstIndex(where: { $0.title == "Закрепленные" }) {
                let pinnedCategory = trackerCategories.remove(at: pinnedIndex)
                trackerCategories.insert(pinnedCategory, at: 0)
            }
            
            categories = trackerCategories
            visibleCategories = trackerCategories.filter { !$0.trackers.isEmpty }
            collectionView.reloadData()
            updateUI()
        } catch {
            print("Failed to load trackers and categories: \(error)")
        }
    }
    
    private func syncData() {
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        fetchCategory()
        fetchRecord()
        if !categories.isEmpty {
            visibleCategories = categories
            collectionView.reloadData()
        }
        
        updateUI()
    }

    private func filteredTrackers() {
        let calendar = Calendar.current
        let selectedWeekDay = calendar.component(.weekday, from: currentDate) - 1
        let selectedDayString = WeekDay(rawValue: selectedWeekDay)?.stringValue ?? ""
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedDayString)
            }
            return !filteredTrackers.isEmpty ? TrackerCategory(title: category.title, trackers: filteredTrackers) : nil
        }

        collectionView.reloadData()
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        do {
            if let categoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
                categories[categoryIndex].trackers.append(tracker)
            } else {
                let newCategory = TrackerCategory(
                    title: category.title,
                    trackers: [tracker])
                categories.append(newCategory)
            }
            visibleCategories = categories
            
            if try trackerCategoryStore.fetchCategories().filter({$0.title == category.title}).count == 0 {
                let newCategoryCoreData = TrackerCategory(title: category.title, trackers: [])
                try trackerCategoryStore.addNewCategory(newCategoryCoreData)
            }
            
            createCategoryAndTracker(tracker: tracker, with: category.title)
            fetchCategory()
            collectionView.reloadData()
            loadTrackersAndCategories()
            updateUI()
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = colors.viewBackgroundColor
        
        [collectionView,
         placeholderImageView,
         placeholderLabel, placeholderImageFilter, placeholderLabelFilter, filterButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 10),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            placeholderImageFilter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageFilter.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageFilter.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageFilter.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabelFilter.topAnchor.constraint(equalTo: placeholderImageFilter.bottomAnchor, constant: 10),
            placeholderLabelFilter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 115),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let filterButtonHeight: CGFloat = 50
        let filterButtonBottomInset: CGFloat = 16
        let collectionViewBottomInset = filterButtonHeight + filterButtonBottomInset + 16
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: collectionViewBottomInset, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("Trackers", comment: "Title for the main screen")
        navigationController?.navigationBar.tintColor = colors.navigationBarTintColor
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerButtonTapped))
        navigationItem.leftBarButtonItem = addButton
        navigationItem.leftBarButtonItem?.tintColor = colors.ypBlack
        
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = searchBar
    }
    
    private func updateUI() {
        if visibleCategories.isEmpty {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            placeholderImageFilter.isHidden = true
            placeholderLabelFilter.isHidden = true
            filterButton.isHidden = true
            collectionView.isHidden = true
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            placeholderImageFilter.isHidden = true
            placeholderLabelFilter.isHidden = true
            collectionView.isHidden = false
            filterButton.isHidden = false
            collectionView.reloadData()
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            assertionFailure("Unable to dequeue TrackerCollectionViewCell")
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count
        
        cell.configure(
            with: tracker,
            trackerIsCompleted: isCompletedToday, 
            completedDays: completedDays,
            indexPath: indexPath
        )
        
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.trackerID == id && isSameDay
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = SupplementaryView.reuseIdentifier
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as! SupplementaryView
        
        let title = visibleCategories[indexPath.section].title
        view.setTitle(title)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        var height = CGFloat()
        if section == 0 {
            height = 42
        } else {
            height = 34
        }
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
            width: collectionView.frame.width,
            height: height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: (collectionView.bounds.width - 9) / 2,
            height: 148
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 9
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
        if currentDate <= Date() {
            let trackerRecord = TrackerRecord(trackerID: id, date: datePicker.date)
            completedTrackers.insert(trackerRecord)
            do {
                try trackerRecordStore.addNewRecord(from: trackerRecord)
                collectionView.reloadItems(at: [indexPath])
            } catch {
                print("Error adding record: \(error)")
            }
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        if let trackerRecordToDelete = completedTrackers.first(where: { $0.trackerID == id }) {
            completedTrackers.remove(trackerRecordToDelete)
            do {
                try trackerRecordStore.deleteTrackerRecord(trackerRecord: trackerRecordToDelete)
                collectionView.reloadItems(at: [indexPath])
                updateStatistic()
            } catch {
                print("Error deleting record: \(error)")
            }
        }
    }
    
    private func updateStatistic() {
        if let statisticVC = self.tabBarController?.viewControllers?.compactMap({ $0 as? UINavigationController }).first(where: { $0.viewControllers.contains(where: { $0 is StatisticViewController }) })?.viewControllers.first(where: { $0 is StatisticViewController }) as? StatisticViewController {
            statisticVC.updateStat()
        }
    }
    
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        let newRecord = TrackerRecord(trackerID: id, date: currentDate)
        
        switch sender {
        case true:
            completedTrackers.insert(newRecord)
        case false:
            completedTrackers.remove(newRecord)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func pinTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let currentCategory = visibleCategories[indexPath.section].title
        
        if currentCategory == "Закрепленные" {
            unpinTracker(at: indexPath)
        } else {
            pinTracker(tracker, from: currentCategory)
        }
        
        fetchCategoryAndUpdateUI()
        loadTrackersAndCategories()
    }
    
    func unpinTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        try? trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, from: "Закрепленные")
        if let originalCategory = originalCategories[tracker.id] {
            try? trackerCategoryStore.addNewTrackerToCategory(tracker, to: originalCategory)
            originalCategories.removeValue(forKey: tracker.id)
        }
        
        fetchCategoryAndUpdateUI()
        loadTrackersAndCategories()
    }
    
    func isTrackerPinned(at indexPath: IndexPath) -> Bool {
        return visibleCategories[indexPath.section].title == "Закрепленные"
    }
    
    private func pinTracker(_ tracker: Tracker, from category: String) {
        ensurePinnedCategoryExists()
        try? trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, from: category)
        originalCategories[tracker.id] = category
        try? trackerCategoryStore.addNewTrackerToCategory(tracker, to: "Закрепленные")
        
        fetchCategoryAndUpdateUI()
        loadTrackersAndCategories()
    }
    
    private func fetchCategoryAndUpdateUI() {
        fetchCategory()
        visibleCategories = categories
        
        if let pinnedIndex = visibleCategories.firstIndex(where: { $0.title == "Закрепленные" }) {
            let pinnedCategory = visibleCategories.remove(at: pinnedIndex)
            visibleCategories.insert(pinnedCategory, at: 0)
        }
        
        collectionView.reloadData()
    }
    
    private func ensurePinnedCategoryExists() {
        let pinnedCategoryTitle = "Закрепленные"
        do {
            if try !trackerCategoryStore.fetchCategories().contains(where: { $0.title == pinnedCategoryTitle }) {
                let newCategory = TrackerCategory(title: pinnedCategoryTitle, trackers: [])
                try trackerCategoryStore.addNewCategory(newCategory)
            }
        } catch {
            print("Failed to ensure pinned category exists: \(error)")
        }
    }
    
    func editTracker(at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        let vc = NewHabitViewController()
        vc.delegate = self
        let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
        vc.categoryName = self.visibleCategories[indexPath.section].title
        vc.selectedCategory = self.visibleCategories[indexPath.section]
        vc.setupEditTracker(tracker: tracker)
        vc.isEditingTracker = true
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        let alert = UIAlertController(
            title: "",
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) {
            [weak self] _ in
            guard let self = self else { return }
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
            trackerStore.deleteTracker(tracker: tracker)

            fetchCategoryAndUpdateUI()
            loadTrackersAndCategories()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { _ in }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func setDateForNewTracker() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    func didCreateNewTracker(_ tracker: Tracker, _ category: TrackerCategory) {
        addTracker(tracker, to: category)
    }
    
    func didEditTracker(_ tracker: Tracker, _ newCategory: TrackerCategory) {
        var oldCategoryIndex: Int?
        var oldTrackerIndex: Int?

        for (categoryIndex, category) in visibleCategories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == tracker.id }) {
                oldCategoryIndex = categoryIndex
                oldTrackerIndex = trackerIndex
                break
            }
        }

        if let oldCategoryIndex = oldCategoryIndex, let oldTrackerIndex = oldTrackerIndex {
            visibleCategories[oldCategoryIndex].trackers.remove(at: oldTrackerIndex)

            if visibleCategories[oldCategoryIndex].trackers.isEmpty {
                visibleCategories.remove(at: oldCategoryIndex)
            }
        }

        if let newCategoryIndex = visibleCategories.firstIndex(where: { $0.title == newCategory.title }) {
            visibleCategories[newCategoryIndex].trackers.append(tracker)
        } else {
            visibleCategories.append(newCategory)
        }

        if let updatedTrackerCoreData = trackerStore.updateTracker(tracker) {
            if let oldCategoryIndex = oldCategoryIndex {
                let oldCategoryTitle = visibleCategories[oldCategoryIndex].title
                try? trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, from: oldCategoryTitle)
            }

            try? trackerCategoryStore.addNewTrackerToCategory(tracker, to: newCategory.title)
        }
        
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        collectionView.reloadData()
    }
}

extension TrackersViewController {
    private func fetchCategory() {
        do {
            let coreDataCategories = try trackerCategoryStore.fetchCategories()
            categories = coreDataCategories.compactMap { coreDataCategory in
                trackerCategoryStore.updateTrackerCategory(coreDataCategory)
            }

            var trackers = [Tracker]()
            
            for visibleCategory in visibleCategories {
                for tracker in visibleCategory.trackers {
                    let newTracker = Tracker(
                        id: tracker.id,
                        name: tracker.name,
                        color: tracker.color,
                        emoji: tracker.emoji,
                        schedule: tracker.schedule)
                    trackers.append(newTracker)
                }
            }
            
            self.trackers = trackers
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    private func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: titleCategory)
    }
}

extension TrackersViewController {
    private func fetchRecord()  {
        do {
            completedTrackers = try trackerRecordStore.fetchRecords()
            collectionView.reloadData()
        } catch {
            print("Ошибка при добавлении записи: \(error)")
        }
    }
    
    private func createRecord(record: TrackerRecord)  {
        do {
            try trackerRecordStore.addNewRecord(from: record)
            fetchRecord()
        } catch {
            print("Ошибка при добавлении записи: \(error)")
        }
    }
    
    private func deleteRecord(record: TrackerRecord)  {
        do {
            try trackerRecordStore.deleteTrackerRecord(trackerRecord: record)
            fetchRecord()
        } catch {
            print("Ошибка при удалении записи: \(error)")
        }
    }
}

extension TrackersViewController {
    private func applyFilter() {
        switch currentFilter {
        case .all:
            filteredTrackers()
        case .today:
            visibleCategories = categories.map { category in
                let trackersForToday = category.trackers.filter { tracker in
                    return isTrackerScheduledForToday(tracker: tracker)
                }
                return TrackerCategory(title: category.title, trackers: trackersForToday)
            }.filter { !$0.trackers.isEmpty }
            collectionView.reloadData()
        case .completed:
            visibleCategories = categories.map { category in
                let completedTrackers = category.trackers.filter { tracker in
                    return isTrackerCompletedOnDate(tracker: tracker, date: currentDate)
                }
                return TrackerCategory(title: category.title, trackers: completedTrackers)
            }.filter { !$0.trackers.isEmpty }
            collectionView.reloadData()
        case .notCompleted:
            visibleCategories = categories.map { category in
                let notCompletedTrackers = category.trackers.filter { tracker in
                    return !isTrackerCompletedOnDate(tracker: tracker, date: currentDate) && isTrackerScheduledForToday(tracker: tracker)
                }
                return TrackerCategory(title: category.title, trackers: notCompletedTrackers)
            }.filter { !$0.trackers.isEmpty }
            collectionView.reloadData()
        }
        
        if visibleCategories.isEmpty {
            showPlaceholder()
        } else {
            hidePlaceholder()
        }
    }
    
    private func isTrackerScheduledForToday(tracker: Tracker) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: currentDate) - 1
        let todayString = WeekDay(rawValue: today)?.stringValue ?? ""
        return tracker.schedule.contains(todayString)
    }
    
    private func isTrackerCompletedOnDate(tracker: Tracker, date: Date) -> Bool {
        return completedTrackers.contains { record in
            record.trackerID == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func showPlaceholder() {
        placeholderImageFilter.isHidden = false
        placeholderLabelFilter.isHidden = false
        collectionView.isHidden = true
    }
    
    private func hidePlaceholder() {
        placeholderImageFilter.isHidden = true
        placeholderLabelFilter.isHidden = true
        collectionView.isHidden = false
    }
}

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        applyFilter()
    }
}


