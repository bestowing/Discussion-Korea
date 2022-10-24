//
//  Chat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation

struct Chat {

    var uid: String?
    var userID: String
    var profileURL: URL?
    var content: String
    var date: Date?
    var nickName: String?
    var side: Side?
    var toxic: Bool?
    var isBlocked: Bool?

    public init(userID: String, content: String, date: Date) {
        self.userID = userID
        self.content = content
        self.date = date
    }

}

extension Chat: Equatable {
    static func ==(lhs: Chat, rhs: Chat) -> Bool {
        return lhs.uid! == rhs.uid! && lhs.date == rhs.date && lhs.toxic == rhs.toxic
    }
}
