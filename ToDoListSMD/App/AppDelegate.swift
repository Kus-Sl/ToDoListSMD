//
//  AppDelegate.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 26.07.2022.
//

import UIKit
import CocoaLumberjack

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let todoService = TodoService(FileCacheService(), NetworkService())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let listViewModel = ListViewModel(todoService)
        let listViewController = ListViewController(listViewModel)
        let navigationController = UINavigationController(rootViewController: listViewController)
        setupNavigationController(navigationController)
        setupLogger()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
        return true
    }
}

// MARK: Support methods
extension AppDelegate {
    private func setupNavigationController(_ controller: UINavigationController) {
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

    private func setupLogger() {
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7

        let formatter = LogFormatter()
        DDOSLogger.sharedInstance.logFormatter = formatter
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(fileLogger)
    }
}
