//
//  DefaultGuideNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

final class DefaultGuideNavigator: BaseNavigator, GuideNavigator {

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

    func toGuide() {
        let viewController = GuideViewController()
        let viewModel = GuideViewModel(
            navigator: self,
            guideUsecase: self.services.makeGuideUsecase()
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
