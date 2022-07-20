//
//  ChatRoomItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation

final class ChatRoomItemViewModel {

    let chatRoom: ChatRoom
    var latestChat: Chat?
    var users: UInt

    var title: String {
        return self.chatRoom.title
    }

    var latestChatContent: String? {
        return self.latestChat?.content
    }

    var latestChatDate: String? {
        guard let date = self.latestChat?.date
        else { return nil }
        let dateString = self.dateFormatter.string(from: date)
        return dateString
    }

    var numbersOfUser: String {
        return "\(self.users)"
    }

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        return dateFormatter
    }()

    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.latestChat = nil
        self.users = 1
    }

}
