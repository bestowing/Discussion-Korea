//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import UIKit

protocol HomeNavigator {

    func toHome()

}

final class DefaultHomeNavigator: HomeNavigator {

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    deinit {
        print(#function, self)
    }

    func toHome() {
        let homeViewController = HomeViewController()
        let homeViewModel = HomeViewModel(navigator: self)
        homeViewController.viewModel = homeViewModel
        self.navigationController.pushViewController(homeViewController, animated: true)
    }

}
