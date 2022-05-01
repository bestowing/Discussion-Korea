//
//  ChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/30.
//

import Domain
import UIKit

protocol ChatRoomNavigator {

    func toChatRoom()

}

final class DefaultChatRoomNavigator: ChatRoomNavigator {

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

    func toChatRoom() {
        guard let chatRoomViewController = self.storyboard.instantiateViewController(
            identifier: ChatRoomViewController.identifier
        ) as? ChatRoomViewController
        else { return }
        let chatRoomViewModel = ChatRoomViewModel(
            usecase: self.services.makeChatsUsecase(), navigator: self
        )
        chatRoomViewController.viewModel = chatRoomViewModel
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
    }

}
