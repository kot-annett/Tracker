//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Anna on 20.05.2024.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didAddNewCategory(_ category: TrackerCategory)
}

final class NewCategoryViewController: UIViewController {
    private var enteredCategoryName = ""
    let trackerCategoryStore = TrackerCategoryStore()
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.maxLength = 38
        textField.layer.cornerRadius = 16
        textField.textColor = .black
        return textField
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkReadyButtonAvailability()
    }
    
    @objc private func readyButtonTapped(_ sender: UIButton) {
        guard let enteredCategoryName = nameTextField.text, !enteredCategoryName.isEmpty else {
            return
        }
        do {
            let newCategory = TrackerCategory(title: enteredCategoryName, trackers: [])
            try trackerCategoryStore.addNewCategory(newCategory)
            delegate?.didAddNewCategory(newCategory)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Ошибка при добавлении категории: \(error)")
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Новая категория"
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
    }
    
    private func checkReadyButtonAvailability() {
        guard let name = nameTextField.text, !name.isEmpty else {
            readyButton.isEnabled = false
            readyButton.backgroundColor = .gray
            return
        }
        readyButton.isEnabled = true
        readyButton.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
    }
    
    private func setupUI() {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameTextField.frame.height))
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        
        [nameTextField, readyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

