//
//  TabBarViewController.swift
//  Tracker
//

import UIKit

final class TabBarViewController: UITabBarController {
    private let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
    private let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .Blue
        tabBar.barTintColor = .BackgroundDay
        tabBar.layer.borderWidth = 1
        updateBorderColor()
        generateTabBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateBorderColor()
            }
        }
    }
    
    private func updateBorderColor() {
        if #available(iOS 13.0, *) {
            let borderColor: UIColor
            if traitCollection.userInterfaceStyle == .light {
                borderColor = .lightGray
            } else {
                borderColor = .black
            }
            tabBar.layer.borderColor = borderColor.cgColor
        } else {
            tabBar.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    private func generateTabBar() {
        viewControllers = [
            generateViewController(viewController: trackersViewController,
                                   title: NSLocalizedString("Trackers", comment: ""),
                                   image: UIImage(named: "TrackersTabBarButton")),
            generateViewController(viewController: statisticViewController,
                                   title: NSLocalizedString("Statistics", comment: ""),
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
