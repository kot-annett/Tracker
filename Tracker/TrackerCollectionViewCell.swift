//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Anna on 09.04.2024.
//

import Foundation
import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var days: [String] = ["дней", "день", "дня"]
    private var quantity: Int = 0
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let emojiImageView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private let quantityButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
//        button.setPreferredSymbolConfiguration((.init(pointSize: 12)), forImageIn: .normal)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.addTarget(
            self,
            action: #selector(quantityButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker) {
        nameLabel.text = tracker.name
        colorView.backgroundColor = tracker.color
        quantityButton.backgroundColor = tracker.color
        emojiImageView.text = tracker.emoji
    }
    
    func trackerIsCompleted(_ sender: Bool) {
        switch sender {
        case true:
            quantityButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            quantityButton.alpha = 0.3
        case false:
            quantityButton.setImage(UIImage(systemName: "plus"), for: .normal)
            quantityButton.alpha = 1
        }
    }
    
    func buttonIsEnabled(_ sender: Bool) {
        switch sender {
        case true:
            quantityButton.isEnabled = true
        case false:
            quantityButton.isEnabled = false
            quantityButton.alpha = 0
        }
    }
    
    func setQuantity(_ sender: Int) {
        quantity = sender
        setQuantityLabelText()
    }
    
    @objc private func quantityButtonTapped() {
        switch quantityButton.currentImage {
        case UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate):
            trackerIsCompleted(true)
            quantity += 1
            setQuantityLabelText()
            delegate?.record(true, self)
        case UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate):
            trackerIsCompleted(false)
            quantity -= 1
            setQuantityLabelText()
            delegate?.record(false, self)
        case .none:
            break
        case .some(_):
            break
        }
    }
   
    private func setQuantityLabelText() {
        switch quantity {
        case 1:
            quantityLabel.text = "\(quantity) \(days[1])"
        case 2...4:
            quantityLabel.text = "\(quantity) \(days[2])"
        default:
            quantityLabel.text = "\(quantity) \(days[0])"
        }
        
        if quantity % 10 == 1 && !(quantity % 100 == 11) {
            quantityLabel.text = "\(quantity) \(days[1])"
        }
        
        for i in 2...4 {
            if quantity % 10 == i && !(quantity % 100 == i + 10) {
                quantityLabel.text = "\(quantity) \(days[2])"
            }
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        [colorView, nameLabel, emojiImageView, quantityLabel, quantityButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [colorView, emojiImageView, quantityButton, quantityLabel, nameLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiImageView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiImageView.heightAnchor.constraint(equalToConstant: 24),
            emojiImageView.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            quantityButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            quantityButton.heightAnchor.constraint(equalToConstant: 34),
            quantityButton.widthAnchor.constraint(equalToConstant: 34),
            
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.trailingAnchor.constraint(equalTo: quantityButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityButton.centerYAnchor)
        ])
    }
}

