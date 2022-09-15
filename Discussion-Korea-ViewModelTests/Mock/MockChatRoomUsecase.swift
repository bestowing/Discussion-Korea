//
//  MockChatRoomUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/08.
//

import RxSwift

final class MockChatRoomUsecase: ChatRoomsUsecase {

    // MARK: - properties

    var chatRoomsStream: Observable<ChatRoom>
    var participateStream: Observable<Void>
    var createChatRoomStream: Observable<Void>
    var latestChatStream: Observable<Chat>
    var userNumberStream: Observable<UInt>
    var firstEnteringStream: Observable<Bool>

    // MARK: - init/deinit

    init() {
        self.chatRoomsStream = PublishSubject<ChatRoom>.init()
        self.participateStream = PublishSubject<Void>.init()
        self.createChatRoomStream = PublishSubject<Void>.init()
        self.latestChatStream = PublishSubject<Chat>.init()
        self.userNumberStream = PublishSubject<UInt>.init()
        self.firstEnteringStream = PublishSubject<Bool>.init()
    }

    // MARK: - methods

    func chatRooms(userID: String, participant: Bool) -> Observable<ChatRoom> {
        return self.chatRoomsStream
    }

    func participate(userID: String, chatRoomID: String) -> Observable<Void> {
        return self.participateStream
    }

    func create(chatRoom: ChatRoom) -> Observable<Void> {
        return self.createChatRoomStream
    }
    
    func latestChat(chatRoomID: String) -> Observable<Chat> {
        return self.latestChatStream
    }
    
    func numberOfUsers(chatRoomID: String) -> Observable<UInt> {
        return self.userNumberStream
    }

    func isFirstEntering(userID: String, chatRoomID: String) -> Observable<Bool> {
        return self.firstEnteringStream
    }

}
