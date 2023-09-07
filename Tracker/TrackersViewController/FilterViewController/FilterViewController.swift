//
//  FilterViewController.swift
//  Tracker
//

import UIKit

final class FilterViewController: UIViewController {
    private let filters: [String] = [
        "Все трекеры", "Трекеры на сегодня",
        "Завершенные", "Не завершенные"
    ]
    
    private let userDefaults = UserDefaults.standard
    
    weak var delegate: FilterDelegate?
    
    private var editingIndex: IndexPath? {
        didSet {
            guard let indexPath = editingIndex else { return }
            let selectedRow = indexPath.row
            userDefaults.set(selectedRow, forKey: "editingIndex")
            userDefaults.synchronize()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: view.bounds.size.width,
                                                  height: view.bounds.height),
                                    style: .insetGrouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedRow = userDefaults.object(forKey: "editingIndex") as? Int {
            editingIndex = IndexPath(row: savedRow, section: 0)
        }
        setupView()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        cell.backgroundColor = .defaultColor
        cell.accessoryType = indexPath == editingIndex ? .checkmark : .none
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            delegate?.showAllTrackers()
        case 1:
            delegate?.showTrackersForToday()
        case 2:
            delegate?.showCompletedTrackersForSelectedDay()
        case 3:
            delegate?.showUnCompletedTrackersForSelectedDay()
        default:
            break
        }
        
        if let editingIndex = editingIndex {
            let previousSelectedCell = tableView.cellForRow(at: editingIndex)
            previousSelectedCell?.accessoryType = .none
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        editingIndex = indexPath
        
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
    }
}
