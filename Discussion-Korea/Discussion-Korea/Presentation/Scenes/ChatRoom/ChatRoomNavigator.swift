//
//  ChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import UIKit

protocol ChatRoomNavigator {

    func toChatRoom()

}

final class DefaultChatRoomNavigator: ChatRoomNavigator {

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

    func toChatRoom() {
        let chatRoomViewController = ChatRoomViewController()
        let chatRoomViewModel = ChatRoomViewModel(
            chatsUsecase: self.services.makeChatsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            navigator: self
        )
        chatRoomViewController.viewModel = chatRoomViewModel
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
    }

}
