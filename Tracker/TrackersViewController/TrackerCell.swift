//
//  TrackerCell.swift
//  Tracker
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func updateTrackerRecord(on cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .BlackDay
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = colorView.backgroundColor
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        [colorView, counterLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        [emojiLabel, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            colorView.addSubview($0)
        }
        
        self.backgroundColor = .white
        
        // MARK: - Layouts
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 90),
            colorView.topAnchor.constraint(equalTo: topAnchor),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            textLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            counterLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            completeButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -12),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            completeButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    // MARK: - Action
    @objc
    private func buttonTapped() {
        guard let currentViewController = findParentViewController() as? TrackersViewController else { return }
        let currentDate = currentViewController.currentDate
        
        let now = Date()
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        if currentDateComponents.year! < nowComponents.year! || (currentDateComponents.year! == nowComponents.year! && currentDateComponents.month! < nowComponents.month!) || (currentDateComponents.year! == nowComponents.year! && currentDateComponents.month! == nowComponents.month! && currentDateComponents.day! <= nowComponents.day!) {
            guard let delegate = delegate else { return }
            delegate.updateTrackerRecord(on: self)
        } else {
            showAlert("Нельзя отмечать трекеры для будущих дат")
        }
    }
    // MARK: - Functions
    func setup(tracker: Tracker) {
        colorView.backgroundColor = tracker.color
        textLabel.text = tracker.name
        emojiLabel.text = tracker.emojie
        completeButton.backgroundColor = tracker.color
    }
    
    func updateTracker(days: Int, isCompleted: Bool) {
        updateButton(isCompleted: isCompleted)
        updateCounterText(days: days)
    }
    
    private func updateButton(isCompleted: Bool) {
        let image: UIImage = (isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus"))!
        completeButton.setImage(image, for: .normal)
        let buttonOpacity: Float = isCompleted ? 0.3 : 1
        completeButton.layer.opacity = buttonOpacity
    }
    
    private func updateCounterText(days: Int) {
        switch days % 10 {
        case 1:
            counterLabel.text = "\(days) день"
        case 2 ... 4:
            counterLabel.text = "\(days) дня"
        default:
            counterLabel.text = "\(days) дней"
        }
    }
    
    private func findParentViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    private func showAlert(_ message: String) {
        if let parentalViewController = findParentViewController() {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            parentalViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
