//
//  DefaultSignUpNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit

final class DefaultSignUpNavigator: BaseNavigator, SignUpNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toSignUp() {
        let viewController = SignUpViewController()
        viewController.viewModel = SignUpViewModel(
            navigator: self, userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toSignIn() {
        self.presentedViewController.dismiss(animated: true)
    }

}
