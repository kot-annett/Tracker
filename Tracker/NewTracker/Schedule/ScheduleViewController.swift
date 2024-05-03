//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Anna on 18.04.2024.
//

import Foundation
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay: Bool])
}

final class ScheduleViewController: UIViewController {
    
    private let titles = Constant.scheduleTableViewTitles
    var selectedDays: [WeekDay: Bool] = [:]
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavigationBar()
        setupUI()
        
        WeekDay.allCases.forEach {
            selectedDays[$0] = false
        }
    }
    
    @objc private func readyButtonTapped() {
        delegate?.didSelectDays(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchViewChanged(sender: UISwitch) {
        guard let cell = sender.superview?.superview as? ScheduleTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let day = WeekDay.allCases[indexPath.row]
        selectedDays[day] = sender.isOn
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Расписание"
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
    }
    
    private func setupUI() {
       
        [tableView, readyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleTableViewCell else { return UITableViewCell() }
        
        cell.switchView.addTarget(
            self,
            action: #selector(switchViewChanged),
            for: .valueChanged
        )
        
        cell.configure(
            title: titles[indexPath.row],
            isSwithcOn: selectedDays[WeekDay.allCases[indexPath.row]] ?? false
        )
        
//        cell.textLabel?.text = titles[indexPath.row]
        
        print("Cell for row \(indexPath.row) configured")
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    } 
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
