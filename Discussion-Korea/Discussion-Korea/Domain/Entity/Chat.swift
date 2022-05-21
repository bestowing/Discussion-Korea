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
    var content: String
    var date: Date?
    var nickName: String?
    var side: Side?
    var toxic: Bool?

    public init(userID: String, content: String, date: Date) {
        self.userID = userID
        self.content = content
        self.date = date
    }

}
