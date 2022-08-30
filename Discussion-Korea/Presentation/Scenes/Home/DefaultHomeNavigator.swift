//
//  DefaultHomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import UIKit

final class DefaultHomeNavigator: BaseNavigator, HomeNavigator {

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

    // MARK: - methods

    func toHome() {
        let homeViewController = HomeViewController()
//        homeViewController.title = "홈"
//        self.navigationController.navigationBar.prefersLargeTitles = true
        self.navigationController.setNavigationBarHidden(true, animated: false)
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

    func toChart() {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultChartNavigator(
            presentedViewController: presentingViewController
        )
        navigator.toChart()
    }

    func toLaw() {
        
    }

    func toGuide() {
        
    }

}
