//
//  SceneDelegate.swift
//  Tracker
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let userDefaults = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)

        let isFirstLaunch = userDefaults.bool(forKey: "isFirstLaunch")
        
        if isFirstLaunch {
            window.rootViewController = TabBarViewController()
        } else {
            window.rootViewController = OnboardingPageViewController()
            userDefaults.set(true, forKey: "isFirstLaunch")
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

