//
//  MockChatRoomUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/08.
//

import RxSwift

final class MockChatRoomUsecase: ChatRoomsUsecase {

    // MARK: properties

    var chatRoomsStream: Observable<ChatRoom>
    var createChatRoomStream: Observable<Void>
    var latestChatStream: Observable<Chat>
    var userNumberStream: Observable<UInt>

    // MARK: - init/deinit

    init() {
        self.chatRoomsStream = PublishSubject<ChatRoom>.init()
        self.createChatRoomStream = PublishSubject<Void>.init()
        self.latestChatStream = PublishSubject<Chat>.init()
        self.userNumberStream = PublishSubject<UInt>.init()
    }

    // MARK: - methods

    func chatRooms() -> Observable<ChatRoom> {
        return self.chatRoomsStream
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

}
