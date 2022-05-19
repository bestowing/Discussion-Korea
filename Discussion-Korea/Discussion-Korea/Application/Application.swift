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

        let homeNavigationController = UINavigationController()
        let homeButton = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        homeNavigationController.tabBarItem = homeButton
        let homeNavigator = DefaultHomeNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: homeNavigationController
        )

        let chatRoomListNavigationController = UINavigationController()
        let chatRoomListButton = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "bubble.left"),
            selectedImage: UIImage(systemName: "bubble.left.fill")
        )
        chatRoomListNavigationController.tabBarItem = chatRoomListButton
        let chatRoomListNavigator = DefaultChatRoomListNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: chatRoomListNavigationController
        )

        let settingNavigationController = UINavigationController()
        let settingButton = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        settingNavigationController.tabBarItem = settingButton
        let settingNavigator = DefaultSettingNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: settingNavigationController
        )

        let tapBarController = UITabBarController()
        tapBarController.viewControllers = [
            homeNavigationController,
            chatRoomListNavigationController,
            settingNavigationController
        ]
        tapBarController.tabBar.tintColor = .primaryColor
        homeNavigator.toHome()
        chatRoomListNavigator.toChatRoomList()
        settingNavigator.toSetting()
        window.rootViewController = tapBarController
        window.makeKeyAndVisible()
    }

}
