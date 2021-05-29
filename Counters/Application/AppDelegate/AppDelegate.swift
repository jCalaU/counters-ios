//
//  AppDelegate.swift
//  Counters
//
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    var navigationController = UINavigationController()
    
    // MARK: - Initialization
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Start UIWindow
        let window = UIWindow()
        window.tintColor = .accentColor
        window.rootViewController = getRootViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
    
    // MARK: - Private Implementation

    func getRootViewController() -> (UIViewController) {
        
        if !UserDefaults.standard.welcomeSeen {
            // WelcomeView
            NotificationCenter.default.addObserver(self, selector:#selector(WelcomeViewPressContinue(notification:)),name:WelcomeView.NotifPressContinue,object: nil)
            let presenter = WelcomeViewPresenter()

            return WelcomeViewController(presenter: presenter)
        } else {
            // CounterListView
            let presenter = CountersListViewPresenter()
            let barPresenter = CountersBarPresenter()
            let viewController = CountersListViewController(presenter: presenter, barPresenter: barPresenter)
            navigationController.setViewControllers([viewController], animated: false)

            return navigationController
        }
    }
    
    @objc func WelcomeViewPressContinue(notification: Notification) {
        UserDefaults.standard.welcomeSeen = true
        guard let windowApp = self.window, let root = windowApp.rootViewController else {
            return
        }
        
        let presenter = CountersListViewPresenter()
        let barPresenter = CountersBarPresenter()
        let viewController = CountersListViewController(presenter: presenter, barPresenter: barPresenter)
        navigationController.setViewControllers([viewController], animated: false)
        
        root.dismiss(animated: false) {
            windowApp.rootViewController = self.navigationController
        }
    }
}

