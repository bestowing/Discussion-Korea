//
//  FirebaseUserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseAuth
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
            if (2...12) ~= nickname.count {
                subscribe.onNext(.success)
            } else {
                subscribe.onNext(.failure("닉네임의 길이는 2자 이상, 12자 이하로 해주세요"))
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    /// 회원 등록
    func register(userInfo: (String, String)) -> Observable<Void> {
        return Observable.create { subscribe in
            Auth.auth()
                .createUser(withEmail: userInfo.0, password: userInfo.1) { authResult, error in
                    guard let _ = authResult,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.signUpError)
                        return
                    }
                    subscribe.onNext(())
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    /// 로그인
    func signIn(userInfo: (email: String, password: String)) -> Observable<Void> {
        return Observable.create { subscribe in
            Auth.auth()
                .signIn(withEmail: userInfo.email, password: userInfo.password) { authResult, error in
                    guard let _ = authResult,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.signUpError)
                        return
                    }
                    subscribe.onNext(())
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    /// 로그아웃
    func signOut() -> Observable<Void> {
        return Observable.create { subscribe in
            do {
                try Auth.auth().signOut()
                subscribe.onNext(())
                subscribe.onCompleted()
            } catch let error {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func resetPassword(_ email: String) -> Observable<Void> {
        return Observable.create { subscribe in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                guard error == nil
                else {
                    subscribe.onError(error!)
                    return
                }
                subscribe.onNext(())
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
    }

    func add(userInfo: (String, String, Date?, URL?)) -> Observable<Void> {
        return self.reference.add(userInfo: userInfo)
    }

    func add(roomID: String, userID: String) -> Observable<Void> {
        return self.reference.add(userID: userID, in: roomID)
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.reference.add(side: side, in: roomID, with: userID)
    }

    func clearSide(roomID: String, userID: String) -> Observable<Void> {
        return self.reference.update(side: nil, in: roomID, with: userID)
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.reference.vote(side: side, in: roomID, with: userID)
    }

    func userInfo(roomID: String, with userID: String) -> Observable<Side?> {
        return self.reference.userInfo(in: roomID, with: userID)
    }

    func userInfos(roomID: String) -> Observable<[String: UserInfo]> {
        return self.reference.userInfos(in: roomID)
    }

    func userInfo(userID: String) -> Observable<UserInfo?> {
        return self.reference.userInfo(with: userID)
    }

    func support(side: Side, roomID: String, userID: String) -> Observable<Void> {
        return self.reference.support(side: side, in: roomID, with: userID)
    }

    func supporter(roomID: String, userID: String) -> Observable<Side> {
        return self.reference.supporters(in: roomID)
            .filter { $0.0 == userID }
            .map { $0.1 }
    }

    func report(from userID: String, to victimID: String, reason: String) -> Observable<Void> {
        return self.reference.report(from: userID, to: victimID, reason: reason)
    }

    func blockers(from userID: String) -> Observable<[String]> {
        return self.reference.blockers(from: userID)
    }

}
