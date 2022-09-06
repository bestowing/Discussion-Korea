//
//  DefaultMyPageNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import UIKit

final class DefaultMyPageNavigator: BaseNavigator, MyPageNavigator {

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

    func toMyPage(_ userID: String) {
        let myPageViewController = MyPageViewController()
        let myPageViewModel = MyPageViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        myPageViewController.viewModel = myPageViewModel
        self.navigationController.pushViewController(myPageViewController, animated: true)
        self.presentingViewController = myPageViewController
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
