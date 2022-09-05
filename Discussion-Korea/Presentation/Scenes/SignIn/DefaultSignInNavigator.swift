//
//  DefaultSignInNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit

final class DefaultSignInNavigator: BaseNavigator, SignInNavigator {

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

    func toSignIn() {
        let viewController = SignInViewController()
        viewController.viewModel = SignInViewModel(
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        self.navigationController.pushViewController(viewController, animated: false)
        self.presentingViewController = viewController
    }

    func toSignUp() {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultSignUpNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toSignUp()
    }

    // TODO: 구현 필요
    func toResetPassword() {}

}
