//
//  Chat.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/16.
//

import Foundation

struct Chat {

    var userID: String
    var content: String
    var date: Date?
    var nickName: String?

    enum Toxic: String {
        case femaleOrFamily = "여성/가족에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case male = "남성에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case sexualMinority = "성 소수자에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case raceOrNationality = "인종/국적에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case age = "특정 연령에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case region = "특정 지역에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case religion = "종교에 대한 비방성 표현을 자제해 주시기 바랍니다."
        case aversion = "혐오성 발언을 자제해 주시기 바랍니다."
        case abuse = "욕설을 자제해 주시기 바랍니다."
        case individual = "특정 개인을 지칭하는 비방성 표현을 자제해 주시기 바랍니다."
        case clean = "비방성 표현을 자제해 주시기 바랍니다."

        static func toToxic(from string: String) -> Toxic {
            switch string {
            case "여성/가족":
                return .femaleOrFamily
            case "남성":
                return .male
            case "성소수자":
                return .sexualMinority
            case "인종/국적":
                return .raceOrNationality
            case "연령":
                return .age
            case "지역":
                return .region
            case "종교":
                return .religion
            case "혐오":
                return .abuse
            case "욕설":
                return .abuse
            case "개인지칭":
                return .individual
            default:
                return .clean
            }
        }
    }

}
