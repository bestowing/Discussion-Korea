//
//  UserInfoManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/29.
//

import Combine
import FirebaseDatabase
import Foundation

final class UserInfoManager {

    static let shared = UserInfoManager()

    var userInfos: [String: UserInfo]

    private init() {
        self.userInfos = [:]
    }

    func observe() {
        let reference = ReferenceManager.reference
        reference.child("users").observe(.childAdded) { [unowned self] snapshot in
            guard let dictionary = snapshot.value as? NSDictionary,
                  let nickname = dictionary["nickname"] as? String
            else {
                return
            }
            print(nickname)
            let userInfo = UserInfo(uid: snapshot.key, nickname: nickname)
            self.userInfos[snapshot.key] = userInfo
        }
    }

}
