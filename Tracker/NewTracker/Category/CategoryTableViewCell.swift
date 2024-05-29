//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Anna on 20.05.2024.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryTableViewCell"
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkbox: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "checkmark"))
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, check: Bool) {
        titleLabel.text = title
        checkbox.isHidden = !check
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkbox)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupContentView() {
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        selectionStyle = .none
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .black
    }
}
