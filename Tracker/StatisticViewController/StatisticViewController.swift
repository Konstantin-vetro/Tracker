//
//  StatisticViewController.swift
//  Tracker
//

import UIKit

final class StatisticViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
