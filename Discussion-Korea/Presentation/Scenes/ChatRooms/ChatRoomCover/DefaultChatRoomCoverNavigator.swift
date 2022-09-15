//
//  DefaultChatRoomCoverNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/13.
//

import UIKit

final class DefaultChatRoomCoverNavigator: BaseNavigator, ChatRoomCoverNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom) {
        let viewController = ChatRoomCoverViewController()
        viewController.viewModel = ChatRoomCoverViewModel(
            uid: userID,
            chatRoom: chatRoom,
            navigator: self,
            chatRoomsUsecase: self.services.makeChatRoomsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toChatRoom() {
        
    }

    func toChatRoomFind() {
        self.presentedViewController.dismiss(animated: true)
    }

}
