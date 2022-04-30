//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import UIKit
import Domain

protocol HomeNavigator {

    func toHome()
    func toChatRoom()

}

final class DefaultHomeNavigator: HomeNavigator {

    private let services: UsecaseProvider
    private let navigationController: UINavigationController
    private let storyboard: UIStoryboard

    init(services: UsecaseProvider,
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
        guard let chatRoomViewController = self.storyboard.instantiateViewController(withIdentifier: ChatRoomViewController.identifier) as? ChatRoomViewController
        else { return }
//        let chatRoomViewModel = ChatRoomViewModel
//        viewController.viewModel = PostsViewModel(useCase: services.makeChatsUsecase(),
//                                      navigator: self)
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
    }

}

extension NSObject {

    static var identifier: String { String(describing: self) }

}
