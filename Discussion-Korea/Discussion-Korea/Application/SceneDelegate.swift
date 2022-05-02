//
//  SceneDelegate.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: properties

    var window: UIWindow?

    // MARK: methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowScene = windowScene

        Application.shared.configureMainInterface(in: window)

        self.window = window
    }

}
