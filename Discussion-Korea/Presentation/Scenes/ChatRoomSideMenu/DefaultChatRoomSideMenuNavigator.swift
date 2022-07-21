//
//  DefaultChatRoomSideMenuNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import SideMenu
import UIKit

final class DefaultChatRoomSideMenuNavigator: ChatRoomSideMenuNavigator {

    final class DefaultSideMenuNavigation: SideMenuNavigationController {

        override func viewDidLoad() {
            super.viewDidLoad()
            self.settings = self.makeSettings()
        }

        private func makeSettings() -> SideMenuSettings {
            var settings = SideMenuSettings()
            settings.presentDuration = 0.3
            settings.dismissDuration = 0.3
            settings.presentationStyle = .menuSlideIn

            let presentationStyle = SideMenuPresentationStyle.menuSlideIn

            presentationStyle.presentingEndAlpha = 0.5
            settings.presentationStyle = presentationStyle
            settings.menuWidth = self.view.frame.width * 0.8
            return settings
        }

    }

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toChatRoomSideMenu(_ uid: String, _ chatRoom: ChatRoom) {
        let viewController = ChatRoomSideMenuViewController()
        let viewModel = ChatRoomSideMenuViewModel(
            uid: uid,
            chatRoom: chatRoom,
            navigator: self
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            discussionUsecase: self.services.makeDiscussionUsecase()
        )
        viewController.viewModel = viewModel
        let menu = DefaultSideMenuNavigation(rootViewController: viewController)
        menu.isNavigationBarHidden = true
        self.presentedViewController.present(menu, animated: true)
    }

    func toChatRoomSchedule(_ chatRoom: ChatRoom) {
        self.presentedViewController.dismiss(animated: true)
        let navigator = DefaultChatRoomScheduleNavigator(
            services: self.services,
            presentedViewController: self.presentedViewController
        )
        navigator.toChatRoomSchedule(chatRoom)
    }

}
