//
//  ChatItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/01.
//

import Domain
import Foundation

class ChatItemViewModel {

    let chat: Chat
    var identifier: String {
        fatalError("not implemented")
    }

    init(with chat: Chat) {
        self.chat = chat
    }

}

final class SelfChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        SelfMessageCollectionViewCell.identifier
    }

}

final class OtherChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        MessageCollectionViewCell.identifier
    }

}

final class OtherChatContItemViewModel: ChatItemViewModel {

    override var identifier: String {
        SerialMessageCollectionViewCell.identifier
    }

}
