//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import UIKit

protocol HomeNavigator {

    func toHome()
    func toEnterGame(_ userID: String)

}

final class DefaultHomeNavigator: HomeNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toHome() {
        let homeViewController = HomeViewController()
        homeViewController.title = "홈"
        self.navigationController.navigationBar.prefersLargeTitles = true
        let homeViewModel = HomeViewModel(
            navigator: self, userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        homeViewController.viewModel = homeViewModel
        self.navigationController.pushViewController(homeViewController, animated: true)
        self.presentingViewController = homeViewController
    }

    func toEnterGame(_ userID: String) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultEnterGuestNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toEnterGuest(userID)
    }

}
