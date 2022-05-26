//
//  EnterGuestNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import UIKit

protocol EnterGuestNavigator {

    func toEnterGuest(_ userID: String)
    func toHome()

}

final class DefaultEnterGuestNavigator: EnterGuestNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toEnterGuest(_ userID: String) {
        let viewController = EnterGuestViewController()
        let viewModel = EnterGuestViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toHome() {
        self.presentedViewController.dismiss(animated: true)
    }

}
