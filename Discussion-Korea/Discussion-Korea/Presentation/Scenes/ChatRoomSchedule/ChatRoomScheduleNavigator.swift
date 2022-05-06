//
//  ChatRoomScheduleNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import UIKit

protocol ChatRoomScheduleNavigator {

    func toChatRoomSchedule()

}

final class DefaultChatRoomScheduleNavigator: ChatRoomScheduleNavigator {

    private let services: UsecaseProvider
    private weak var presentingViewController: UIViewController?

    init(services: UsecaseProvider, presentingViewController: UIViewController?) {
        self.services = services
        self.presentingViewController = presentingViewController
    }

    func toChatRoomSchedule() {
        let viewController = ChatRoomScheduleViewController()
        let viewModel = ChatRoomScheduleViewModel()
        viewController.viewModel = viewModel
        self.presentingViewController?.present(viewController, animated: true)
    }

}
