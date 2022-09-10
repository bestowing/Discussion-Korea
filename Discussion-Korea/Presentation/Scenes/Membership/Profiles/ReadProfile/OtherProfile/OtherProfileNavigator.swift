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
        let viewController = MyProfileViewController()
        viewController.viewModel = ReadProfileViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        viewController.modalPresentationStyle = .pageSheet
        self.presentedViewController.present(viewController, animated: true)
    }

    func toSetting() {}
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?) {}

}
