//
//  StatisticViewController.swift
//  Tracker
//

import UIKit

final class StatisticViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .BackgroundDay
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("Statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
