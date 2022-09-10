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

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toReadProfile(_ userID: String) {
        let viewController = OtherProfileViewController()
        viewController.viewModel = ReadProfileViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        viewController.modalPresentationStyle = .pageSheet
        self.presentedViewController.present(viewController, animated: true)
    }

    func dismiss() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toReport() {
        // TODO: 구현 필요
    }

}

extension OtherProfileNavigator {

    func toSetting() {}
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?) {}

}
