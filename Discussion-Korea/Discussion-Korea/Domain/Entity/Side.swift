//
//  Side.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/13.
//

enum Side: String {
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
