//
//  Application.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import UIKit

final class Application {

    static let shared = Application()

    private let firebaseUseCaseProvider: UsecaseProvider

    private init() {
        self.firebaseUseCaseProvider = FirebaseUsecaseProvider()
    }

    func configureMainInterface(in window: UIWindow) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance

        let navigationController = UINavigationController()
        let homeNavigator = DefaultHomeNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: navigationController
        )
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        homeNavigator.toHome()
    }

}
