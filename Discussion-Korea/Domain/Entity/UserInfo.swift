//
//  UserInfo.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation

struct UserInfo {

    let uid: String
    let nickname: String
    let registerAt: Date
    var position: String?
    var profileURL: URL?
    var side: Side?
    var win: Int
    var draw: Int
    var lose: Int

    init(uid: String, nickname: String, registerAt: Date) {
        self.uid = uid
        self.nickname = nickname
        self.registerAt = registerAt
        self.position = nil
        self.profileURL = nil
        self.win = 0
        self.draw = 0
        self.lose = 0
    }

}
