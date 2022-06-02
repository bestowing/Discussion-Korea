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
//        #if DEBUG
//        let reference = Database
//            .database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
//            .reference()
//        #elseif RELEASE
        let reference = Database
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
//        #endif
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
