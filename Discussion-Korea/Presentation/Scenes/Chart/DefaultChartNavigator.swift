//
//  DefaultChartNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

final class DefaultChartNavigator: BaseNavigator, ChartNavigator {

    // MARK: properties

    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(presentedViewController: UIViewController) {
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toChart() {
        let viewController = ChartViewController()
        let viewModel = ChartViewModel(navigator: self)
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toHome() {
        self.presentedViewController.dismiss(animated: true)
    }

}
