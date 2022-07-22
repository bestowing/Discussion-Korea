//
//  MockUserInfoUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/08.
//

import RxSwift

final class MockUserInfoUsecase: UserInfoUsecase {

    // MARK: properties

    var addEventStream: Observable<Void>
    var addSideEventStream: Observable<Void>
    var addUserInfoStream: Observable<Void>
    var clearSideStream: Observable<Void>
    var voteStream: Observable<Void>
    var uidStream: Observable<String>
    var roomUserInfoStream: Observable<UserInfo?>
    var connectStream: Observable<UserInfo>
    var userInfoStream: Observable<UserInfo?>
    var supportStream: Observable<Void>
    var supporterStream: Observable<Side>

    // MARK: - init/deinit

    init() {
        self.addEventStream = PublishSubject<Void>.init()
        self.addSideEventStream = PublishSubject<Void>.init()
        self.addUserInfoStream = PublishSubject<Void>.init()
        self.clearSideStream = PublishSubject<Void>.init()
        self.voteStream = PublishSubject<Void>.init()
        self.uidStream = PublishSubject<String>.init()
        self.roomUserInfoStream = PublishSubject<UserInfo?>.init()
        self.connectStream = PublishSubject<UserInfo>.init()
        self.userInfoStream = PublishSubject<UserInfo?>.init()
        self.supportStream = PublishSubject<Void>.init()
        self.supporterStream = PublishSubject<Side>.init()
    }

    // MARK: - methods

    func add(roomID: String, userID: String) -> Observable<Void> {
        return self.addEventStream
    }

    func add(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.addSideEventStream
    }

    func add(userInfo: UserInfo) -> Observable<Void> {
        return self.addUserInfoStream
    }

    func clearSide(roomID: String, userID: String) -> Observable<Void> {
        return self.clearSideStream
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return self.voteStream
    }

    func uid() -> Observable<String> {
        return self.uidStream
    }

    func userInfo(roomID: String, with userID: String) -> Observable<UserInfo?> {
        return self.roomUserInfoStream
    }

    func connect(roomID: String) -> Observable<UserInfo> {
        return self.connectStream
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
