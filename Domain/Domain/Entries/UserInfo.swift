//
//  UserInfo.swift
//  Domain
//
//  Created by 이청수 on 2022/04/29.
//

import Foundation

public struct UserInfo {

    public enum Side: String {
        case agree = "agree"
        case disagree = "disagree"
        case judge = "judge"
        case observer = "observer"

        static func toSide(from string: String) -> Side {
            switch string {
            case "agree":
                return Side.agree
            case "disagree":
                return Side.disagree
            case "judge":
                return Side.judge
            default:
                return Side.observer
            }
        }

    }

    public let userID: String
    public let nickname: String
    public var isAdmin: Bool
    public var side: Side?
    public var profileURL: URL?
    public var description: String?

    public init(userID: String, nickname: String, isAdmin: Bool) {
        self.userID = userID
        self.nickname = nickname
        self.isAdmin = isAdmin
    }

}
