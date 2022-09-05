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
    }

    // TODO: 구현 필요
    func toSignUp() {}

    // TODO: 구현 필요
    func toResetPassword() {}

}
