//
//  NewTrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Anna on 04.05.2024.
//

import Foundation
import UIKit

final class NewTrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "NewTrackerCollectionViewCell"
    
    private let emojiPickView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let colorPickView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.alpha = 0.3
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if !emojiLabel.isHidden {
                self.emojiPickView.isHidden = isSelected ? false : true
            }
            if !colorView.isHidden {
                self.colorPickView.isHidden = isSelected ? false : true
            }
        }
    }
    
    func setEmoji(_ model: String) {
        emojiLabel.text = model
        emojiLabel.isHidden = false
    }
    
    func setColor(_ model: UIColor) {
        colorView.backgroundColor = model
        colorView.isHidden = false
        colorPickView.layer.borderColor = model.cgColor
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        [emojiPickView, emojiLabel, colorPickView, colorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            emojiPickView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiPickView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiPickView.heightAnchor.constraint(equalToConstant: 52),
            emojiPickView.widthAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorPickView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorPickView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorPickView.heightAnchor.constraint(equalToConstant: 52),
            colorPickView.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}
