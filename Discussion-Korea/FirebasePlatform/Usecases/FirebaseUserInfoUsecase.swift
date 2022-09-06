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

    func isValid(email: String) -> Observable<FormResult> {
        return Observable.create { subscribe in
            // 전체 5자 이상, 64자 이하, 알파벳 대/소문자, 숫자, _-만 허용
            let regex = "^[A-Za-z0-9_-]+@[A-Za-z]+\\.[A-Za-z]{2,20}$"
            if let _ = email.range(of: regex, options: .regularExpression) {
                subscribe.onNext(.success)
            } else {
                subscribe.onNext(.failure("이메일 형식이 맞지 않습니다"))
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func isValid(password: String) -> Observable<FormResult> {
        return Observable.create { subscribe in
            // 8자리 이상, 20자리 이하, 알파벳 대소문자, 숫자, !@#$%만 허용
            let regex = "[A-Za-z0-9!@#$%]{8,20}"
            if let _ = password.range(of: regex, options: .regularExpression) {
                subscribe.onNext(.success)
            } else {
                subscribe.onNext(.failure("비밀번호 형식이 맞지 않습니다"))
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func isValid(nickname: String) -> Observable<FormResult> {
        return Observable.create { subscribe in
            if (8...20) ~= nickname.count {
                subscribe.onNext(.success)
            } else {
                subscribe.onNext(.failure("닉네임이 형식에 맞지 않습니다"))
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func register(userInfo: (String, String)) -> Observable<Void> {
        return self.reference.register(userInfo: userInfo)
    }

    func signIn(userInfo: (email: String, password: String)) -> Observable<Void> {
        return self.reference.signIn(userInfo: userInfo)
    }

    func signOut() -> Observable<Void> {
        return self.reference.signOut()
    }

    func add(userInfo: (String, String, URL?)) -> Observable<Void> {
        self.reference.add(userInfo: userInfo)
    }

    func add(roomID: String, userID: String) -> Observable<Void> {
        self.reference.add(userID: userID, in: roomID)
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        self.reference.add(side: side, in: roomID, with: userID)
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
