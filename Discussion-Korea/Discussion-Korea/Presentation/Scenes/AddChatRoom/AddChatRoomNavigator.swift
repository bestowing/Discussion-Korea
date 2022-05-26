//
//  AddChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import UIKit

protocol AddChatRoomNavigator {

    func toAddChatRoom()
    func toChatRoomList()

}

final class DefaultAddChatRoomNavigator: AddChatRoomNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toAddChatRoom() {
        let viewController = AddChatRoomViewController()
        let viewModel = AddChatRoomViewModel(
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            chatRoomUsecase: self.services.makeChatRoomsUsecase()
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toChatRoomList() {
        self.presentedViewController.dismiss(animated: true)
    }

}
