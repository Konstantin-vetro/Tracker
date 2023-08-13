//
//  TrackerCell.swift
//  Tracker
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func plusButtonTapped(on cell: TrackerCell)
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
    
    private lazy var plusButton: UIButton = {
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
        [colorView, counterLabel, plusButton].forEach {
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
            
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc
    private func buttonTapped() {
        let now = Date()
        if let trackersViewController = findParentViewController() as? TrackersViewController,
           trackersViewController.currentDate <= now {
            guard let delegate = delegate else { return }
            delegate.plusButtonTapped(on: self)
        } else {
            showAlert("Нельзя отмечать трекеры для будущих дат")
        }
    }
    
// MARK: - Functions
    func setupCell(tracker: Tracker) {
        colorView.backgroundColor = tracker.color
        textLabel.text = tracker.name
        emojiLabel.text = tracker.emojie
        plusButton.backgroundColor = tracker.color
    }
    
    func didCompleteTracker(days: Int, isToday: Bool) {
        updatePlusButton(trackerCompleted: isToday)
        updateCounterText(days: days)
    }

    private func updatePlusButton(trackerCompleted: Bool) {
        let image: UIImage = (trackerCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus"))!
        plusButton.setImage(image, for: .normal)
        let buttonOpacity: Float = trackerCompleted ? 0.3 : 1
        plusButton.layer.opacity = buttonOpacity
    }
    
    private func updateCounterText(days: Int) {
        switch days % 10 {
        case 1:
            counterLabel.text = "\(days) день"
        case 2:
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
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            parentalViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
