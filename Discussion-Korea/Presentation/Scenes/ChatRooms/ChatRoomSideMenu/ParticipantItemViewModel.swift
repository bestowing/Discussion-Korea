//
//  ParticipantItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

final class ParticipantItemViewModel {

    var userInfo: UserInfo

    var nickname: String {
        var name = self.userInfo.nickname
        var descriptions = [String]()
        if let position = self.userInfo.position {
            switch position {
            case "admin":
                descriptions.append("방장")
            default:
                break
            }
        }
        if self.isSelf {
            descriptions.append("나")
        }
        let description = descriptions.joined(separator: ", ")
        if !description.isEmpty {
            name += " (\(description))"
        }
        return name
    }

    private let isSelf: Bool

    init(with userInfo: UserInfo, isSelf: Bool) {
        self.userInfo = userInfo
        self.isSelf = isSelf
    }
    
    init(userInfo: UserInfo) {
        self.userInfo = UserInfo(uid: userInfo.uid, nickname: "차단한 사용자", registerAt: userInfo.registerAt)
        self.isSelf = false
    }

}
