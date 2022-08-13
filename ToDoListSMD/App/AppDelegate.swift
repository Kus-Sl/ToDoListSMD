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
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 16

        let standardNavigationBarAppearance = UINavigationBarAppearance()
        standardNavigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.ColorAsset.labelPrimary]
        standardNavigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.ColorAsset.labelPrimary, .paragraphStyle: style]
        standardNavigationBarAppearance.backgroundColor = .ColorAsset.backPrimary
        standardNavigationBarAppearance.shadowColor = nil

        controller.navigationBar.standardAppearance = standardNavigationBarAppearance
        controller.navigationBar.tintColor = .ColorAsset.colorBlue
        controller.navigationBar.prefersLargeTitles = true
    }
}
