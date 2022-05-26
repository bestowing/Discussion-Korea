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

    func add(roomID: String, userInfo: UserInfo) -> Observable<Void> {
        self.reference.add(userInfo, to: roomID)
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        self.reference.setSide(roomID: roomID, userID: userID, side: side)
    }

    func add(userInfo: UserInfo) -> Observable<Void> {
        self.reference.add(userInfo: userInfo)
    }

    func clearSide(roomID: String, userID: String) -> Observable<Void> {
        self.reference.clearSide(from: roomID, of: userID)
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        self.reference.vote(roomID: roomID, userID: userID, side: side)
    }

    func uid() -> Observable<String> {
        return Observable<String>.create { [unowned self] in
            $0.onNext(self.getUID())
            $0.onCompleted()
            return Disposables.create()
        }
    }

    func userInfo(roomID: String, with userID: String) -> Observable<UserInfo?> {
        return self.reference.getUserInfo(in: roomID, with: userID)
    }

    func connect(roomID: String) -> Observable<UserInfo> {
        self.reference.getUserInfo(from: roomID)
    }

    func userInfo(userID: String) -> Observable<UserInfo?> {
        self.reference.getUserInfo(userID: userID)
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
