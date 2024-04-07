//
//  ViewController.swift
//  Tracker
//
//  Created by Anna on 05.04.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [searchBar,
         placeholderImageView,
         placeholderLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
    }
    
    @objc private func addTrackerButtonTapped() {
        // TODO: action for button
    }
    
    
}

