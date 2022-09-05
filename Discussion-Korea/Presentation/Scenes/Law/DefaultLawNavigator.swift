//
//  DefaultLawNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

final class DefaultLawNavigator: BaseNavigator, LawNavigator {

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

    func toLaw() {
        let viewController = LawViewController()
        let viewModel = LawViewModel(
            navigator: self,
            lawUsecase: self.services.makeLawUsecase()
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.navigationController = navigationController
    }

    func toHome() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toLawDetail(_ law: Law) {
        guard let navigationController = self.navigationController
        else { return }
        let navigator = DefaultLawDetailNavigator(
            navigationController: navigationController
        )
        navigator.toLawDetail(law)
    }

}
