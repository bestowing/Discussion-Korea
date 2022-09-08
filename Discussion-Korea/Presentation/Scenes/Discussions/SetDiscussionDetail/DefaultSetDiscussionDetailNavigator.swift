//
//  DefaultSetDiscussionDetailNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import UIKit

final class DefaultSetDiscussionDetailNavigator: SetDiscussionDetailNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider, navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    // MARK: - methods

    func toSetDiscussionDetail(_ chatRoom: ChatRoom) {
        let viewController = SetDiscussionDetailViewController()
        viewController.viewModel = SetDiscussionDetailViewModel(
            chatRoom: chatRoom,
            navigator: self,
            builderUsecase: self.services.makeBuilderUsecase(),
            discussionUsecase: self.services.makeDiscussionUsecase()
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    func toChatRoom() {
        self.navigationController.presentingViewController?.dismiss(animated: true)
    }

}
