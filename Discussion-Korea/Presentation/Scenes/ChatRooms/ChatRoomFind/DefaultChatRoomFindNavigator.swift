//
//  DefaultChatRoomFindNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/15.
//

import UIKit

final class DefaultChatRoomFindNavigator: BaseNavigator, ChatRoomListNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toChatRoomFind(_ userID: String) {
        let viewController = ChatRoomFindViewController()
        viewController.viewModel = ChatRoomListViewModel(
            participant: false,
            userID: userID,
            navigator: self,
            chatRoomsUsecase: self.services.makeChatRoomsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.presentingViewController = viewController
    }

    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom) {
        guard let presentingViewController = self.presentingViewController
        else { return }
        let navigator = DefaultChatRoomCoverNavigator(
            services: self.services, presentedViewController: presentingViewController
        )
        navigator.toChatRoomCover(userID, chatRoom)
    }

    func toChatRoomList(_ userID: String) {
        self.presentedViewController.dismiss(animated: true)
    }

}

extension DefaultChatRoomFindNavigator {

    func toChatRoom(_ userID: String, _ chatRoom: ChatRoom) {}
    func toAddChatRoom(_ userID: String) {}

}
