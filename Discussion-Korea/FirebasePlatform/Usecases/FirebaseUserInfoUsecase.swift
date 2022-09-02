//
//  FirebaseUserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxSwift

final class FirebaseUserInfoUsecase: UserInfoUsecase {

    private let reference: UserInfoReference

    init(reference: UserInfoReference) {
        self.reference = reference
    }

    func add(roomID: String, userID: String) -> Observable<Void> {
        self.reference.add(userID: userID, in: roomID)
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        self.reference.add(side: side, in: roomID, with: userID)
    }

    func add(userInfo: (String, String, URL?)) -> Observable<Void> {
        self.reference.add(userInfo: userInfo)
    }

    func clearSide(roomID: String, userID: String) -> Observable<Void> {
        self.reference.update(side: nil, in: roomID, with: userID)
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        self.reference.vote(side: side, in: roomID, with: userID)
    }

    func uid() -> Observable<String> {
        return Observable<String>.create { [unowned self] in
            $0.onNext(self.getUID())
            $0.onCompleted()
            return Disposables.create()
        }
    }

    func userInfo(roomID: String, with userID: String) -> Observable<Side?> {
        return self.reference.userInfo(in: roomID, with: userID)
    }

    func userInfos(roomID: String) -> Observable<[String: UserInfo]> {
        self.reference.userInfos(in: roomID)
    }

    func userInfo(userID: String) -> Observable<UserInfo?> {
        self.reference.userInfo(with: userID)
    }

    func support(side: Side, roomID: String, userID: String) -> Observable<Void> {
        return self.reference.support(side: side, in: roomID, with: userID)
    }

    func supporter(roomID: String, userID: String) -> Observable<Side> {
        return self.reference.supporters(in: roomID)
            .filter { $0.0 == userID }
            .map { $0.1 }
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
