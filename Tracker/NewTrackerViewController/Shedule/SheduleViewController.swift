//
//  SheduleViewController.swift
//  Tracker
//

import UIKit

final class SheduleViewController: UIViewController {    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200), style: .insetGrouped)
        tableView.register(SheduleViewCell.self, forCellReuseIdentifier: SheduleViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .BlackDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveWeekDays), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: HabitDelegate?
    
    private let weekDays: [String] = [
        "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    private var shedule: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Layouts
    private func setupViews() {
        [tableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: tableView.rowHeight * 8),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    // MARK: - Action
    @objc
    private func saveWeekDays() {
        delegate?.addDetailDays(shedule)
        dismiss(animated: true)
    }
}
// MARK: - UITableViewDataSource
extension SheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SheduleViewCell.identifier,
            for: indexPath
        ) as? SheduleViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = weekDays[indexPath.row]
        cell.backgroundColor = .defaultColor
        cell.delegateCell = self
        return cell
    }
}
// MARK: - SheduleViewCellDelegate
extension SheduleViewController: SheduleViewCellDelegate {
    func didToogleSwitch(for day: String, isOn: Bool) {
        if isOn {
            shedule.append(day)
        } else {
            shedule.removeAll { $0 == day }
        }
    }
}