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

    private weak var presentingViewController: UIViewController?

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
        self.presentingViewController = viewController
    }

    func toSignIn() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toErrorAlert(_ error: Error) {
        guard let presentingViewController = presentingViewController
        else { return }
        let alert = UIAlertController(
            title: "오류!",
            message: "오류가 발생했습니다. 재시도해주세요..",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        presentingViewController.present(alert, animated: true)
    }

}
