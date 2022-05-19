//
//  AddDiscussionNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import UIKit

protocol AddDiscussionNavigator {

    func toAddDiscussion()
    func toChatRoom()

}

final class DefaultAddDiscussionNavigator: AddDiscussionNavigator {

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

    func toAddDiscussion() {
        let viewController = AddDiscussionViewController()
        viewController.viewModel = AddDiscussionViewModel(navigator: self, usecase: self.services.makeDiscussionUsecase())
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
    }

    func toChatRoom() {
        self.presentedViewController.dismiss(animated: true)
    }

}
