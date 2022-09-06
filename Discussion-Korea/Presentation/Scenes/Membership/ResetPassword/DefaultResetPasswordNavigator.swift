//
//  DefaultResetPasswordNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit

final class DefaultResetPasswordNavigator: BaseNavigator, ResetPasswordNavigator {

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

    func toResetPassword() {
        let viewController = ResetPasswordViewController()
        viewController.viewModel = ResetPasswordViewModel(
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
            title: "재설정 메일 발송 실패",
            message: "잠시후에 재시도해주세요",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        presentingViewController.present(alert, animated: true)
    }

    func toSuccessAlert() {
        guard let presentingViewController = presentingViewController
        else { return }
        let alert = UIAlertController(
            title: "재설정 메일 전송",
            message: "재설정 메일이 전송되었어요",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        presentingViewController.present(alert, animated: true)
    }

}
