//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Domain
import UIKit

protocol HomeNavigator {

    func toHome()
    func toChatRoom()

}

final class DefaultHomeNavigator: HomeNavigator {

    private let services: Domain.UsecaseProvider
    private let navigationController: UINavigationController
    private let storyboard: UIStoryboard

    init(services: Domain.UsecaseProvider,
         navigationController: UINavigationController,
         storyboard: UIStoryboard) {
        self.services = services
        self.navigationController = navigationController
        self.storyboard = storyboard
    }

    deinit {
        print(#function, self)
    }

    func toHome() {
        guard let homeViewController = self.storyboard.instantiateViewController(identifier: HomeViewController.identifier) as? HomeViewController
        else { return }
        let homeViewModel = HomeViewModel(navigator: self)
        homeViewController.viewModel = homeViewModel
        self.navigationController.pushViewController(homeViewController, animated: false)
    }

    func toChatRoom() {
        let chatRoomNavigator = DefaultChatRoomNavigator(services: self.services,
                                                         navigationController: self.navigationController,
                                                         storyboard: self.storyboard)
        chatRoomNavigator.toChatRoom()
    }

}

extension NSObject {

    static var identifier: String { String(describing: self) }

}
