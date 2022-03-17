//
//  AppDelegate.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/17.
//

import Firebase
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

}
