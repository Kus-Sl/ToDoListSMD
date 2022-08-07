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

        let navigationController = UINavigationController(rootViewController: DetailViewController())
        setupNavigationController(navigationController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
        return true
    }

    func setupNavigationController(_ controller: UINavigationController) {
        let scrollEdgeNavigationBarAppearance = UINavigationBarAppearance()
        scrollEdgeNavigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.colorAssets.labelPrimary!]
        scrollEdgeNavigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.colorAssets.labelPrimary!]
        scrollEdgeNavigationBarAppearance.backgroundColor = UIColor.colorAssets.backPrimary
        scrollEdgeNavigationBarAppearance.shadowColor = nil

        controller.navigationBar.scrollEdgeAppearance = scrollEdgeNavigationBarAppearance
        controller.navigationBar.tintColor = UIColor.colorAssets.colorBlue
        controller.navigationBar.prefersLargeTitles = true
    }
}
