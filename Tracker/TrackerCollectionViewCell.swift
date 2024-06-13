//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Anna on 09.04.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func record(_ sender: Bool, _ cell: TrackerCollectionViewCell)
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func pinTracker(at indexPath: IndexPath)
    func unpinTracker(at indexPath: IndexPath)
    func editTracker(at indexPath: IndexPath)
    func deleteTracker(at indexPath: IndexPath)
    func isTrackerPinned(at indexPath: IndexPath) -> Bool
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var quantity: Int = 0
    private var trackerIsCompleted: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
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
        label.text = "1 день"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        let interaction = UIContextMenuInteraction(delegate: self)
        colorView.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        with tracker: Tracker,
        trackerIsCompleted: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerIsCompleted = trackerIsCompleted
        self.trackerId = tracker.id
        self.indexPath = indexPath
        
        nameLabel.text = tracker.name
        colorView.backgroundColor = tracker.color
        quantityButton.backgroundColor = tracker.color
        emojiImageView.text = tracker.emoji
        
        let imageName = trackerIsCompleted ? "checkmark" : "plus"
        if let image = UIImage(systemName: imageName) {
            quantityButton.setImage(image, for: .normal)
        }
        
        quantityLabel.text = setQuantityLabelText(completedDays)
        setupQuantityButton(with: tracker)
    }
   
    @objc private func quantityButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId and indexPath")
            return
        }
        
//        quantityButton.isEnabled = false
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if trackerIsCompleted {
                self.delegate?.uncompleteTracker(id: trackerId, at: indexPath)
            } else {
                self.delegate?.completeTracker(id: trackerId, at: indexPath)
            }
//            self.quantityButton.isEnabled = true
//        }
    }
    
    private func setupQuantityButton(with tracker: Tracker) {
        switch quantityButton.currentImage {
        case UIImage(systemName: "plus"):
            colorView.backgroundColor = tracker.color
        case UIImage(systemName: "checkmark"):
            quantityButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
        case .none:
            break
        case .some(_):
            break
        }
        let plusImage = UIImage(systemName: "checkmark")
        let checkImage = UIImage(systemName: "plus")
    }
    
    private func setQuantityLabelText(_ count: Int) -> String {
        let language = Locale.current.languageCode
        
        if language == "ru" {
            // Логика для русского языка
            let daysForms = [
                NSLocalizedString("days_many", comment: "Plural form for days"),
                NSLocalizedString("day", comment: "Singular form for day"),
                NSLocalizedString("days_few", comment: "Few form for days")
            ]

            let remainder100 = count % 100
            let remainder10 = count % 10
            var formIndex: Int
            
            switch remainder100 {
            case 11...14:
                formIndex = 0
            default:
                switch remainder10 {
                case 1:
                    formIndex = 1
                case 2...4:
                    formIndex = 2
                default:
                    formIndex = 0
                }
            }
            
            return "\(count) \(daysForms[formIndex])"
        } else {
            // Логика для английского языка
            let dayString = count == 1 ? NSLocalizedString("day", comment: "Singular form for day") : NSLocalizedString("days_few", comment: "Plural form for days")
            return "\(count) \(dayString)"
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        [colorView, quantityButton, quantityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [emojiImageView, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        colorView.addSubview(emojiImageView)
        colorView.addSubview(nameLabel)
        
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

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPath else { return nil }
        
        let configContextMenu = UIContextMenuConfiguration(actionProvider: { _ in
            let isPinned = self.delegate?.isTrackerPinned(at: indexPath) ?? false
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            
            let pinAction = UIAction(title: pinTitle) { _ in
                if isPinned {
                    self.delegate?.unpinTracker(at: indexPath)
                } else {
                    self.delegate?.pinTracker(at: indexPath)
                }
            }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.delegate?.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить",
                                  attributes: .destructive) { _ in
                self.delegate?.deleteTracker(at: indexPath)
            }
            
            let actions = [pinAction, editAction, deleteAction]
            return UIMenu(title: "", children: actions)
        })
        
        return configContextMenu
    }
}




