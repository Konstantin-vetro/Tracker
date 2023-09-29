//
//  TrackersTypeViewController.swift
//  Tracker
//

import UIKit

final class TrackersTypeViewController: UIViewController {
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        let habit = NSLocalizedString("Habit", comment: "")
        button.setTitle(habit, for: .normal)
        button.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        let event = NSLocalizedString("IrregularEvent", comment: "")
        button.setTitle(event, for: .normal)
        button.addTarget(self, action: #selector(addIreggularEvent), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    weak var delegate: TrackerViewControllerDelegate?
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        [habitButton, irregularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.backgroundColor = .blackDay
            $0.setTitleColor(.backgroundDay, for: .normal)
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
            view.addSubview($0)
        }
        view.backgroundColor = .backgroundDay
    // MARK: - Layout
        NSLayoutConstraint.activate([
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            irregularEventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor)
        ])
    }
    // MARK: - Actions
    @objc
    private func addNewHabit() {
        analyticsService.clickHabitReport()
        let habitViewController = NewTrackerViewController()
        habitViewController.title = NSLocalizedString("NewHabit", comment: "")
        habitViewController.onTrackerCreated = { [weak self] tracker, titleCategory in
            guard let self = self else { return }
            self.delegate?.createTracker(tracker, category: titleCategory ?? "")
        }
        
        let navigationController = UINavigationController(rootViewController: habitViewController)
        navigationController.navigationBar.barTintColor = .backgroundDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func addIreggularEvent() {
        analyticsService.clickEventReport()
        let eventViewController = NewTrackerViewController()
        eventViewController.title = NSLocalizedString("NewEvent", comment: "")
        eventViewController.onTrackerCreated = { [weak self] (tracker, titleCategory) in
            guard let self = self else { return }
            self.delegate?.createTracker(tracker, category: titleCategory ?? "")
        }
        eventViewController.chooseIrregularEvent = true
        
        let navigationController = UINavigationController(rootViewController: eventViewController)
        navigationController.navigationBar.barTintColor = .backgroundDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
}
