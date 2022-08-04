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
        let navigation = UINavigationController(rootViewController: DetailViewController())
        navigation.navigationBar.tintColor = UIColor.colorAssets.colorBlue
        navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.colorAssets.labelPrimary!]

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navigation
        return true
    }
}

