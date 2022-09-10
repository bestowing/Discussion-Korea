//
//  MyProfileNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import UIKit

final class MyProfileNavigator: BaseNavigator, ReadProfileNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    // MARK: - methods

    func toReadProfile(_ userID: String) {
        let viewController = MyProfileViewController()
        viewController.viewModel = ReadProfileViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        self.navigationController.pushViewController(viewController, animated: true)
        self.presentingViewController = viewController
    }

    func toSetting() {
        let navigator = DefaultSettingNavigator(
            services: self.services,
            navigationController: self.navigationController
        )
        navigator.toSetting()
    }

    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = EditProfileNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toConfigureProfile(userID, nickname, profileURL)
    }

}
