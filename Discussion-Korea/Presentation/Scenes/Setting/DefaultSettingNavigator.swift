//
//  DefaultSettingNavigator.swift
//  Discussion-Korea
//
//  Created by μ΄μ²­μ on 2022/07/19.
//

import UIKit

final class DefaultSettingNavigator: SettingNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    deinit {
        print("π", self)
    }

    // MARK: - methods

    func toSetting() {
        self.makeOpaqueNavigationBar()
        let settingViewController = SettingViewController()
        settingViewController.contents = ["μ€νμμ€ λΌμ΄μ μ€ μ΄μ©κ³ μ§"]
        settingViewController.selected = [toOpenSource]
        settingViewController.title = "μ€μ "
        self.navigationController.pushViewController(settingViewController, animated: true)
    }

    private func makeOpaqueNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        self.navigationController.navigationBar.standardAppearance = appearance
    }

    func toOpenSource() {
        let openSourceNavigator = DefaultOpenSourceNavigator(navigationController: self.navigationController)
        openSourceNavigator.toOpenSource()
    }

}
