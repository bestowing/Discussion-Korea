//
//  UserInfo.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/29.
//

import Foundation

struct UserInfo {

    let uid: String
    let nickname: String
    var position: String?
    var profileURL: URL?
    var side: Side?

    public init(uid: String, nickname: String) {
        self.uid = uid
        self.nickname = nickname
        self.position = nil
        self.profileURL = nil
    }

}
