//
//  NewEventTableViewCell.swift
//  Tracker
//
//  Created by Anna on 11.04.2024.
//

import Foundation
import UIKit

final class NewEventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "NewEventTableViewCell"
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = .gray
        return image
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        selectionStyle = .none
        
        [stackView, chevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.heightAnchor.constraint(equalToConstant: 46),
            
            chevronImageView.heightAnchor.constraint(equalToConstant: 15),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setTitle(_ model: String) {
        titleLabel.text = model
    }
    
    func setDescription(_ model: String) {
        descriptionLabel.text = model
        if descriptionLabel.text != "" {
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
}
