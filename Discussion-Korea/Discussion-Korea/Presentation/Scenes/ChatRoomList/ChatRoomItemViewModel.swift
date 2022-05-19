//
//  ChatRoomItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation

final class ChatRoomItemViewModel {

    let chatRoom: ChatRoom

    var title: String {
        return self.chatRoom.title
    }

    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }

}
