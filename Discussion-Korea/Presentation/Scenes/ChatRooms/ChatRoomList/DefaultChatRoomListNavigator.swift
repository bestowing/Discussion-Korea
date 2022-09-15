//
//  DefaultChatRoomListNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import UIKit

final class DefaultChatRoomListNavigator: BaseNavigator, ChatRoomListNavigator {

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

    func toChatRoomList(_ userID: String) {
        let chatRoomListViewController = ChatRoomListViewController()
        let chatRoomListViewModel = ChatRoomListViewModel(
            participant: true,
            userID: userID,
            navigator: self,
            chatRoomsUsecase: self.services.makeChatRoomsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        chatRoomListViewController.viewModel = chatRoomListViewModel
        self.navigationController.pushViewController(chatRoomListViewController, animated: true)
        self.presentingViewController = chatRoomListViewController
    }

    func toChatRoomFind(_ userID: String) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultChatRoomFindNavigator(
            services: self.services,
            presentedViewController: presentingViewController
        )
        navigator.toChatRoomFind(userID)
    }

    func toChatRoom(_ uid: String, _ chatRoom: ChatRoom) {
        let chatRoomNavigator = DefaultChatRoomNavigator(
            services: self.services,
            navigationController: self.navigationController
        )
        chatRoomNavigator.toChatRoom(uid, chatRoom)
    }

    func toAddChatRoom(_ userID: String) {
        guard let presentingViewController = presentingViewController
        else { return }
        let addChatRoomNavigator = DefaultAddChatRoomNavigator(
            services: self.services,
            presentedViewController: presentingViewController
        )
        addChatRoomNavigator.toAddChatRoom(userID)
    }

}

extension DefaultChatRoomListNavigator {

    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom) {}

}
