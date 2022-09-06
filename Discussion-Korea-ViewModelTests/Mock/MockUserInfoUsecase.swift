//
//  MockUserInfoUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/08.
//

import Foundation
import RxSwift

final class MockUserInfoUsecase: UserInfoUsecase {

    // MARK: - properties

    var emailValidStream: Observable<FormResult>
    var passwordValidStream: Observable<FormResult>
    var nicknameValidStream: Observable<FormResult>
    var registerStream: Observable<Void>
    var signInStream: Observable<Void>
    var signOutStream: Observable<Void>
    var resetPasswordStream: Observable<Void>

    var addEventStream: Observable<Void>
    var addSideEventStream: Observable<Void>
    var addUserInfoStream: Observable<Void>
    var clearSideStream: Observable<Void>
    var voteStream: Observable<Void>
    var roomUserInfoStream: Observable<Side?>
    var userInfosStream: Observable<[String : UserInfo]>
    var userInfoStream: Observable<UserInfo?>
    var supportStream: Observable<Void>
    var supporterStream: Observable<Side>

    // MARK: - init/deinit

    init() {
        self.emailValidStream = PublishSubject<FormResult>.init()
        self.passwordValidStream = PublishSubject<FormResult>.init()
        self.nicknameValidStream = PublishSubject<FormResult>.init()
        self.registerStream = PublishSubject<Void>.init()
        self.signInStream = PublishSubject<Void>.init()
        self.signOutStream = PublishSubject<Void>.init()
        self.resetPasswordStream = PublishSubject<Void>.init()

        self.addEventStream = PublishSubject<Void>.init()
        self.addSideEventStream = PublishSubject<Void>.init()
        self.addUserInfoStream = PublishSubject<Void>.init()
        self.clearSideStream = PublishSubject<Void>.init()
        self.voteStream = PublishSubject<Void>.init()
        self.roomUserInfoStream = PublishSubject<Side?>.init()
        self.userInfosStream = PublishSubject<[String : UserInfo]>.init()
        self.userInfoStream = PublishSubject<UserInfo?>.init()
        self.supportStream = PublishSubject<Void>.init()
        self.supporterStream = PublishSubject<Side>.init()
    }

    // MARK: - methods

    func isValid(email: String) -> Observable<FormResult> {
        return self.emailValidStream
    }
    
    func isValid(password: String) -> Observable<FormResult> {
        return self.passwordValidStream
    }
    
    func isValid(nickname: String) -> Observable<FormResult> {
        return self.nicknameValidStream
    }
    
    func register(userInfo: (String, String)) -> Observable<Void> {
        return self.registerStream
    }
    
    func signIn(userInfo: (email: String, password: String)) -> Observable<Void> {
        return self.signInStream
    }
    
    func signOut() -> Observable<Void> {
        return self.signOutStream
    }
    
    func resetPassword(_ email: String) -> Observable<Void> {
        return self.resetPasswordStream
    }

    func add(roomID: String, userID: String) -> Observable<Void> {
        return self.addEventStream
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.addSideEventStream
    }

    func add(userInfo: (String, String, URL?)) -> Observable<Void> {
        return self.addUserInfoStream
    }

    func clearSide(roomID: String, userID: String) -> Observable<Void> {
        return self.clearSideStream
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.voteStream
    }

    func userInfo(roomID: String, with userID: String) -> Observable<Side?> {
        return self.roomUserInfoStream
    }

    func userInfos(roomID: String) -> Observable<[String : UserInfo]> {
        return self.userInfosStream
    }

    func userInfo(userID: String) -> Observable<UserInfo?> {
        return self.userInfoStream
    }

    func support(side: Side, roomID: String, userID: String) -> Observable<Void> {
        return self.supportStream
    }
    
    func supporter(roomID: String, userID: String) -> Observable<Side> {
        return self.supporterStream
    }

}
