//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Anna on 10.04.2024.
//

import Foundation
import UIKit

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private let titles = ["Категория", "Расписание"]
    private let trackerType: TrackerType = .habit
    private let newTrackername: String = ""
    private var categoryName: String = "" {
        didSet {
            if !categoryName.isEmpty {
                print(categoryName)
                tableView.reloadData()
            }
        }
    }
    private var schedule: [String] = []
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    var selectedDays: [WeekDay: Bool] = [:]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let container = UIView()
        return container
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.maxLength = 38
        textField.layer.cornerRadius = 16
        textField.textColor = .black
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(NewHabitTableViewCell.self, forCellReuseIdentifier: NewHabitTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
            )
        collectionView.register(
            NewTrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: NewTrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            NewTrackerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NewTrackerSupplementaryView.reuseIdentifier
        )
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkCreateButtonAvailability()
        nameTextField.delegate = self
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let newTrackerName = nameTextField.text else { return }
        guard let date = delegate?.setDateForNewTracker() else { return }
        var newTrackerSchedule: [String] = []
        
        switch trackerType {
        case .habit:
            if selectedDays.values.contains(true) {
                newTrackerSchedule = selectedDays.filter { $0.value }.map { $0.key.stringValue }
            }
        case .event:
            newTrackerSchedule = [date]
        }
        
        let formattedSchedule = newTrackerSchedule.joined(separator: ", ")
        
        let newTracker = Tracker(
            id: UUID(),
            name: newTrackerName,
            color: selectedColor ?? .orange,
            emoji: selectedEmoji ?? Constant.randomEmoji(),
            schedule: formattedSchedule
        )
        let newCategory = TrackerCategory(title: categoryName, trackers: [newTracker])
        delegate?.didCreateNewTracker(newTracker, newCategory)
        dismiss(animated: true)
    }
    
    private func checkCreateButtonAvailability() {
        guard let name = nameTextField.text, !name.isEmpty else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
            return
        }
        
        createButton.isEnabled = true
        createButton.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
    }
 
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        [nameTextField, tableView, collectionView, buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameTextField.frame.height))
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 27),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 476),
            
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor,constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Новая привычка"
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
    }
}

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewHabitTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? NewHabitTableViewCell else { return UITableViewCell() }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.setTitle(titles[indexPath.row])
        
        if indexPath.row == 0 {
            cell.setDescription(categoryName)
        } else if indexPath.row == 1 {
            let selectedDaysArray = selectedDays.filter { $0.value }.map { $0.key }
            if selectedDaysArray.isEmpty {
                cell.setDescription("") 
            } else if selectedDaysArray.count == WeekDay.allCases.count {
                cell.setDescription("Каждый день") 
            } else {
                let selectedDaysString = selectedDaysArray.map { $0.stringValue }.joined(separator: ", ")
                cell.setDescription(selectedDaysString)
            }
        } 
        
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        if indexPath.row == titles.count - 1 {
            separator.isHidden = true
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let trackerCategoryStore = TrackerCategoryStore()
            let categoryViewModel = CategoryViewModel(trackerCategoryStore: trackerCategoryStore)
            let categoryVC = CategoryViewController(viewModel: categoryViewModel)
            categoryVC.selectedCategory = categoryName
            categoryVC.delegate = self
            navigationController?.pushViewController(categoryVC, animated: true)
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = selectedDays
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        default:
            break
        }
    }
}

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Constant.emojies.count
        case 1:
            return Constant.colorSelection.count
        default:
            return 18
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewTrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? NewTrackerCollectionViewCell else {
            assertionFailure("Unable to dequeue NewTrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        switch indexPath.section {
        case 0:
            cell.setEmoji(Constant.emojies[indexPath.row])
        default:
            if let color = Constant.colorSelection[indexPath.row] {
                cell.setColor(color)
            } 
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = NewTrackerSupplementaryView.reuseIdentifier
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as? NewTrackerSupplementaryView else {
            assertionFailure("Unable to dequeue NewTrackerSupplementaryView")
            return UICollectionReusableView()
        }
        
        let title = Constant.collectionViewTitles[indexPath.section]
        view.setTitle(title)
        
        return view
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: 34),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForVisibleItems.filter({
            $0.section == indexPath.section
        }).forEach({
            collectionView.deselectItem(at: $0, animated: true)
        })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedEmoji = Constant.emojies[indexPath.row]
        case 1:
            selectedColor = Constant.colorSelection[indexPath.row]
        default:
            break
        }
        checkCreateButtonAvailability()
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay: Bool]) {
            selectedDays = days
            tableView.reloadData()
        }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewHabitViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        categoryName = category
        tableView.reloadData()
    }
}
