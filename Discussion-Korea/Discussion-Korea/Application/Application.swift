//
//  Application.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Domain
import FirebasePlatform
import NetworkPlatform
import UIKit

final class Application {

    static let shared = Application()

    private let firebaseUseCaseProvider: Domain.UsecaseProvider
    private let networkUseCaseProvider: Domain.UsecaseProvider

    private init() {
        self.firebaseUseCaseProvider = FirebasePlatform.UsecaseProvider()
        self.networkUseCaseProvider = NetworkPlatform.UsecaseProvider()
    }

    func configureMainInterface(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = UINavigationController()
        let homeNavigator = DefaultHomeNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: navigationController,
            storyboard: storyboard
        )
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        homeNavigator.toHome()
    }

}
