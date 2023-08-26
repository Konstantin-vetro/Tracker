//
//  TabBarViewController.swift
//  Tracker
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
    
    let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .Blue
        tabBar.barTintColor = .white
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.LightGray.cgColor
        generateTabBar()
    }
    
    private func generateTabBar() {
        viewControllers = [
            generateViewController(viewController: trackersViewController,
                                   title: "Трекеры",
                                   image: UIImage(named: "TrackersTabBarButton")),
            generateViewController(viewController: statisticViewController,
                                   title: "Статистика",
                                   image: UIImage(named: "StatisticTabBarButton"))
        ]
    }
    
    private func generateViewController(
        viewController: UIViewController,
        title: String,
        image: UIImage?
    ) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
}
