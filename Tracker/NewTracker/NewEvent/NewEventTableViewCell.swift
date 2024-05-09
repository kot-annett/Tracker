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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
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
        backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        selectionStyle = .none
        
        [descriptionLabel, chevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 22),
            
            chevronImageView.heightAnchor.constraint(equalToConstant: 15),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    func setTitle(_ model: String) {
        descriptionLabel.text = model
    }
}
