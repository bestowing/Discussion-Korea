//
//  DefaultHomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import UIKit

final class DefaultHomeNavigator: BaseNavigator, HomeNavigator {

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

    // MARK: - methods

    func toHome(_ userID: String) {
        let homeViewController = HomeViewController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
        let homeViewModel = HomeViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        homeViewController.viewModel = homeViewModel
        self.navigationController.pushViewController(homeViewController, animated: true)
        self.presentingViewController = homeViewController
    }

    func toFeedback() {
        guard let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScRWypBXvJQOR30o7-E8wnXJmj5zghQMkYG04109iPLDvbcfQ/viewform?usp=sf_link")
        else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func toLaw() {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultLawNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toLaw()
    }

    func toGuide() {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultGuideNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toGuide()
    }

    func toOnboarding(_ userID: String) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = SetProfileNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toConfigureProfile(userID)
    }

}
