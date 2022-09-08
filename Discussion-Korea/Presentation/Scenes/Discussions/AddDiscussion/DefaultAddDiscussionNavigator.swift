//
//  DefaultAddDiscussionNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import UIKit

final class DefaultAddDiscussionNavigator: BaseNavigator, AddDiscussionNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private weak var navigationController: UINavigationController?

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toAddDiscussion(_ chatRoom: ChatRoom) {
        let viewController = AddDiscussionViewController()
        viewController.viewModel = AddDiscussionViewModel(
            chatRoom: chatRoom,
            navigator: self,
            builderUsecase: self.services.makeBuilderUsecase(),
            discussionUsecase: self.services.makeDiscussionUsecase()
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.navigationController = navigationController
    }

    func toSetDiscussionTime(_ chatRoom: ChatRoom) {
        guard let navigationController = self.navigationController
        else { return }
        let navigator = DefaultSetDiscussionDetailNavigator(
            services: self.services,
            navigationController: navigationController
        )
        navigator.toSetDiscussionDetail(chatRoom)
    }

    func toChatRoom() {
        self.presentedViewController.dismiss(animated: true)
    }

}
