//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import UIKit
import Domain

protocol HomeNavigator {

    func toChatRoom()

}

final class DefaultHomeNavigator: HomeNavigator {

    private let services: UsecaseProvider
    private let navigationController: UINavigationController
    private let storyBoard: UIStoryboard

    init(services: UsecaseProvider,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.services = services
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }

    func toChatRoom() {
        let viewController = storyBoard.instantiateViewController(withIdentifier: ChatRoomViewController.identifier)
//        viewController.viewModel = PostsViewModel(useCase: services.makeChatsUsecase(),
//                                      navigator: self)
        self.navigationController.pushViewController(viewController, animated: true)
    }

}

extension NSObject {

    static var identifier: String { String(describing: self) }

}
