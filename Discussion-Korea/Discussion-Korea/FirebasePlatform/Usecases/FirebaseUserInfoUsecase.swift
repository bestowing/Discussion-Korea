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

    func add(room: Int, userInfo: UserInfo) -> Observable<Void> {
        self.reference.addUserInfo(room: room, userInfo: userInfo)
    }

    func add(room: Int, uid: String, side: Side) -> Observable<Void> {
        self.reference.setSide(room: room, uid: uid, side: side)
    }

    func vote(room: Int, uid: String, side: Side) -> Observable<Void> {
        self.reference.vote(room: room, uid: uid, side: side)
    }

    func uid() -> Observable<String> {
        return Observable<String>.create { [unowned self] in
            $0.onNext(self.getUID())
            $0.onCompleted()
            return Disposables.create()
        }
    }

    func userInfo(room: Int, with uid: String) -> Observable<UserInfo?> {
        return self.reference.getUserInfo(in: room, with: uid)
    }

    func connect(room: Int) -> Observable<UserInfo> {
        self.reference.getUserInfo(room: room)
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

}
