//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Anna on 18.04.2024.
//

import Foundation
import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let switchView: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .blue
        switcher.setOn(false, animated: true)
        switcher.addTarget(
            self,
            action: #selector(switchViewChanged),
            for: .valueChanged
        )
        return switcher
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchViewChanged() {
        
    }
    
    func configure(title: String, isSwithcOn: Bool) {
        titleLabel.text = title
        switchView.isOn = isSwithcOn
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        
        [titleLabel, switchView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.widthAnchor.constraint(equalToConstant: 51),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ])
    }
}
