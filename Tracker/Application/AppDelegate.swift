//
//  AppDelegate.swift
//  Tracker
//

import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "fd4abd52-263c-4254-b969-fc026a7624eb") else { return true }
        
        YMMYandexMetrica.activate(with: configuration)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.storyboard = nil
        configuration.sceneClass = UIWindowScene.self
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

