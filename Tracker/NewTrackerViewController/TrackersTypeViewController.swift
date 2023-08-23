//
//  TrackersTypeViewController.swift
//  Tracker
//

import UIKit

final class TrackersTypeViewController: UIViewController {
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.addTarget(self, action: #selector(addIreggularEvent), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TrackerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        [habitButton, irregularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.backgroundColor = .BlackDay
            $0.tintColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
            view.addSubview($0)
        }
        view.backgroundColor = .white
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
        let habitViewController = NewTrackerViewController()
        habitViewController.title = "Новая привычка"
        habitViewController.onTrackerCreated = { [weak self] tracker, titleCategory in
            guard let self = self else { return }
            self.delegate?.createTracker(tracker, titleCategory: titleCategory ?? "")
        }
        
        let navigationController = UINavigationController(rootViewController: habitViewController)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func addIreggularEvent() {
        let eventViewController = NewTrackerViewController()
        eventViewController.title = "Новое нерегулярное событие"
        eventViewController.onTrackerCreated = { [weak self] (tracker, titleCategory) in
            guard let self = self else { return }
            self.delegate?.createTracker(tracker, titleCategory: titleCategory ?? "")
        }
        eventViewController.chooseIrregularEvent = true
        
        let navigationController = UINavigationController(rootViewController: eventViewController)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
}
