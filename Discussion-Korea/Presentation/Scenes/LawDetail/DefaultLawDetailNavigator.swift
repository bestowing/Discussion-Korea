//
//  DefaultLawDetailNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/02.
//

import UIKit

final class DefaultLawDetailNavigator: BaseNavigator, LawDetailNavigator {

    // MARK: properties

    private let navigationController: UINavigationController

    // MARK: - init/deinit

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLawDetail(_ law: Law) {
        let viewController = LawDetailViewController()
        viewController.viewModel = LawDetailViewModel(
            law: law,
            navigator: self
        )
        self.navigationController.pushViewController(viewController, animated: true)
    }

}
