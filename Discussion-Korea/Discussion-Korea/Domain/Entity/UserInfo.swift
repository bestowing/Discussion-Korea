//
//  UserInfo.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation

public struct UserInfo {

    public let uid: String
    public let nickname: String
    public let profileURL: URL?

    public init(uid: String, nickname: String, profileURL: URL?) {
        self.uid = uid
        self.nickname = nickname
        self.profileURL = profileURL
    }

}
