//
//  AppDelegate.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 26.07.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navigationController = UINavigationController(rootViewController: ListViewController())
        setupNavigationController(navigationController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
        return true
    }

    func setupNavigationController(_ controller: UINavigationController) {
        let standardNavigationBarAppearance = UINavigationBarAppearance()
        standardNavigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.colorAssets.labelPrimary!]
        standardNavigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.colorAssets.labelPrimary!]
        standardNavigationBarAppearance.backgroundColor = UIColor.colorAssets.backPrimary
        standardNavigationBarAppearance.shadowColor = nil

        controller.navigationBar.standardAppearance = standardNavigationBarAppearance
        controller.navigationBar.tintColor = UIColor.colorAssets.colorBlue
        controller.navigationBar.prefersLargeTitles = true
    }
}
