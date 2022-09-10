//
//  OtherProfileNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/10.
//

import UIKit

final class OtherProfileNavigator: BaseNavigator, ReadProfileNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private weak var navigationController: UINavigationController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toReadProfile(_ selfID: String, _ userID: String) {
        let viewController = OtherProfileViewController()
        viewController.viewModel = ReadProfileViewModel(
            selfID: selfID,
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.navigationController = navigationController
    }

    func dismiss() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toReport(_ userID: String, _ reportedUserInfo: UserInfo) {
        guard let navigationController = self.navigationController
        else { return }
        let navigator = DefaultReportNavigator(
            services: self.services, navigationController: navigationController
        )
        navigator.toReport(userID, reportedUserInfo)
    }

}

extension OtherProfileNavigator {

    func toSetting() {}
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?) {}

}
