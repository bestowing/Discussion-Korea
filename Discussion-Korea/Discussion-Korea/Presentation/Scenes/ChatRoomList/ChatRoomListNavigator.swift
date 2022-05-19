//
//  ChatRoomListNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import UIKit

protocol ChatRoomListNavigator {

    func toChatRoomList()
    func toChatRoom(_ chatRoom: ChatRoom)

}

final class DefaultChatRoomListNavigator: ChatRoomListNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

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

    func toChatRoomList() {
        let chatRoomListViewController = ChatRoomListViewController()
        chatRoomListViewController.title = "채팅"
        self.navigationController.navigationBar.prefersLargeTitles = true
        let chatRoomListViewModel = ChatRoomListViewModel(
            navigator: self,
            chatRoomsUsecase: self.services.makeChatRoomsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        chatRoomListViewController.viewModel = chatRoomListViewModel
        self.navigationController.pushViewController(chatRoomListViewController, animated: true)
    }

    func toChatRoom(_ chatRoom: ChatRoom) {
        let chatRoomNavigator = DefaultChatRoomNavigator(
            services: self.services,
            navigationController: self.navigationController
        )
        chatRoomNavigator.toChatRoom(chatRoom)
    }

}
