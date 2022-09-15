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

    private weak var navigationController: UINavigationController?
    private weak var chatRoomFindNavigator: ChatRoomFindNavigator?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController,
         chatRoomFindNavigator: ChatRoomFindNavigator) {
        self.services = services
        self.presentedViewController = presentedViewController
        self.chatRoomFindNavigator = chatRoomFindNavigator
    }

    // MARK: - methods

    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom) {
        let viewController = ChatRoomCoverViewController()
        viewController.viewModel = ChatRoomCoverViewModel(
            uid: userID,
            chatRoom: chatRoom,
            navigator: self,
            chatRoomsUsecase: self.services.makeChatRoomsUsecase()
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.navigationController = navigationController
    }

    func toChatRoom(_ userID: String, _ chatRoom: ChatRoom) {
        self.presentedViewController.dismiss(animated: true) {
            self.chatRoomFindNavigator?.toChatRoom(userID, chatRoom)
        }
    }

    func toChatRoomFind() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toReport(_ userID: String, _ reportedUID: String) {
        guard let navigationController = self.navigationController
        else { return }
        let navigator = DefaultReportNavigator(
            services: self.services, navigationController: navigationController
        )
        navigator.toReport(userID, reportedUID)
    }

}
