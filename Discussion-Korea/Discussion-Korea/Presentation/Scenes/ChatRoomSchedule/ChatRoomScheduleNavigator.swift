//
//  ChatRoomScheduleNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import UIKit

protocol ChatRoomScheduleNavigator {

    func toChatRoomSchedule(_ chatRoom: ChatRoom)
    func toAddDiscussion(_ chatRoom: ChatRoom)
    func toChatRoom()

}

final class DefaultChatRoomScheduleNavigator: ChatRoomScheduleNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toChatRoomSchedule(_ chatRoom: ChatRoom) {
        let viewController = ChatRoomScheduleViewController()
        let viewModel = ChatRoomScheduleViewModel(
            chatRoom: chatRoom,
            usecase: self.services.makeDiscussionUsecase(),
            navigator: self
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.presentingViewController = viewController
    }

    func toAddDiscussion(_ chatRoom: ChatRoom) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultAddDiscussionNavigator(
            services: self.services,
            presentedViewController: presentingViewController
        )
        navigator.toAddDiscussion(chatRoom)
    }

    func toChatRoom() {
        self.presentedViewController.dismiss(animated: true)
    }

}
