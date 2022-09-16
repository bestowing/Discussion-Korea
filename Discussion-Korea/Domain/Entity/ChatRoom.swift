//
//  ChatRoom.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation

struct ChatRoom {

    let uid: String
    let title: String
    let adminUID: String
    var profileURL: URL?

}

extension ChatRoom: Equatable {

    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.uid == rhs.uid
    }

}
