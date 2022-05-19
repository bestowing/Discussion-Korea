//
//  SettingNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import UIKit

protocol SettingNavigator {

    func toSetting()

}

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
        print("🗑", self)
    }

    // MARK: - methods

    func toSetting() {
        let settingViewController = SettingViewController()
        let settingViewModel = SettingViewModel(navigator: self)
        settingViewController.viewModel = settingViewModel
        self.navigationController.pushViewController(settingViewController, animated: true)
    }

}
