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

    // MARK: - Initialization
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Notif WelcomeView > PressContinue Button
        NotificationCenter.default.addObserver(self, selector:#selector(WelcomeViewPressContinue(notification:)),name:WelcomeView.NotifPressContinue,object: nil)
            
        // Start UIWindow
        let window = UIWindow()
        let presenter = WelcomeViewPresenter()
        window.rootViewController = WelcomeViewController(presenter: presenter)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
    // MARK: - Private Implementation
    
    @objc func WelcomeViewPressContinue(notification: Notification) {
        
        guard let windowApp = self.window, let root = windowApp.rootViewController else {
            return
        }
        
        let presenter = CountersListViewPresenter()
        let barController = CountersBarController(addAction: {})
        let viewController = CountersListViewController(presenter: presenter, barController: barController)
        
        root.dismiss(animated: false) {
            windowApp.rootViewController = UINavigationController(rootViewController: viewController)
        }
    }
}

