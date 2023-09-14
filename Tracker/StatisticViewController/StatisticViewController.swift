//
//  StatisticViewController.swift
//  Tracker
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        return tableView
    }()
// MARK: - LyfeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.openScreenReport(screen: .statistics)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.closeScreenReport(screen: .statistics)
    }
    
    private func setupUI() {
        view.backgroundColor = .BackgroundDay
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("Statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
