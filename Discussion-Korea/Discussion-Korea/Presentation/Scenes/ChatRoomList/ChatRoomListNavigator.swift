//
//  ChatRoomListNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import UIKit

protocol ChatRoomListNavigator {

    func toChatRoomList()
    func toChatRoom(_ chatRoomID: String)

}

final class DefaultChatRoomListNavigator: ChatRoomListNavigator {

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

    func toChatRoomList() {
        let chatRoomListViewController = ChatRoomListViewController()
        let chatRoomListViewModel = ChatRoomListViewModel(navigator: self)
        chatRoomListViewController.viewModel = chatRoomListViewModel
        self.navigationController.pushViewController(chatRoomListViewController, animated: true)
    }

    func toChatRoom(_ chatRoomID: String) {
        let chatRoomNavigator = DefaultChatRoomNavigator(
            services: self.services,
            navigationController: self.navigationController
        )
        chatRoomNavigator.toChatRoom(chatRoomID)
    }

}