//
//  Application.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Firebase
import FirebaseAuth
import FirebaseCore
import UIKit

final class Application {

    // MARK: - properties

    static let shared = Application()

    private var handle: AuthStateDidChangeListenerHandle?

    private let firebaseUseCaseProvider: UsecaseProvider

    // MARK: - init/deinit

    private init() {
        FirebaseApp.configure()
        self.firebaseUseCaseProvider = FirebaseUsecaseProvider()
    }

    // MARK: - methods

    func configureMainInterface(in window: UIWindow) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance

        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let _ = user {
                self?.toMain(in: window)
            } else {
                self?.toSignIn(in: window)
            }
        }
    }

    private func toMain(in window: UIWindow) {
        let homeNavigationController = UINavigationController()
        let homeButton = UITabBarItem(
            title: "홈",
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
            title: "채팅",
            image: UIImage(systemName: "bubble.left"),
            selectedImage: UIImage(systemName: "bubble.left.fill")
        )
        chatRoomListNavigationController.tabBarItem = chatRoomListButton
        let chatRoomListNavigator = DefaultChatRoomListNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: chatRoomListNavigationController
        )

        let myPageNavigationController = UINavigationController()
        let myPageButton = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        myPageNavigationController.tabBarItem = myPageButton
        let myPageNavigator = DefaultMyPageNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: myPageNavigationController
        )

        let tapBarController = UITabBarController()
        tapBarController.viewControllers = [
            homeNavigationController,
            chatRoomListNavigationController,
            myPageNavigationController
        ]
        tapBarController.tabBar.tintColor = .accentColor
        homeNavigator.toHome()
        chatRoomListNavigator.toChatRoomList()
        myPageNavigator.toMyPage()
        window.rootViewController = tapBarController
        window.makeKeyAndVisible()
    }

    private func toSignIn(in window: UIWindow) {
        let navigationController = UINavigationController()
        let signInNavigator = DefaultSignInNavigator(
            services: self.firebaseUseCaseProvider,
            navigationController: navigationController
        )
        signInNavigator.toSignIn()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

}
