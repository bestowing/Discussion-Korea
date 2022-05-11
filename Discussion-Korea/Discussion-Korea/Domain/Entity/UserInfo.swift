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
    public var position: String?
    public var profileURL: URL?

    public init(uid: String, nickname: String) {
        self.uid = uid
        self.nickname = nickname
        self.position = nil
        self.profileURL = nil
    }

}
