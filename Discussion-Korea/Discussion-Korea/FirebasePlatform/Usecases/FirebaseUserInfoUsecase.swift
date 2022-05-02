//
//  FirebaseUserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxSwift

final class FirebaseUserInfoUsecase: UserInfoUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func uid() -> Observable<String> {
        return Observable.just(self.getUID())
    }

    private func getUID() -> String {
        let key = "userID"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }

    func userInfo() -> Observable<UserInfo> {
        return self.reference.getUserInfo()
    }

}
