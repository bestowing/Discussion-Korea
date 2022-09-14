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

    func toChatRoomCover() {
        
    }

    func toChatRoom() {
        
    }

    func toChatRoomList() {
        
    }

}
