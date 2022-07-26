//
//  MockChatsUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/21.
//

import RxSwift

final class MockChatsUsecase: ChatsUsecase {

    // MARK: properties

    var chatsStream: Observable<[Chat]>
    var connectStream: Observable<Chat>
    var sendEventStream: Observable<Void>
    var maskingStream: Observable<String>
    var editStream: Observable<Void>
    var getEditStream: Observable<Chat?>

    // MARK: - init/deinit

    init() {
        self.chatsStream = PublishSubject<[Chat]>.init()
        self.connectStream = PublishSubject<Chat>.init()
        self.sendEventStream = PublishSubject<Void>.init()
        self.maskingStream = PublishSubject<String>.init()
        self.editStream = PublishSubject<Void>.init()
        self.getEditStream = PublishSubject<Chat?>.init()
    }

    // MARK: - methods

    func chats(roomUID: String) -> Observable<[Chat]> {
        return self.chatsStream
    }
    
    func connect(roomUID: String, after chatUID: String?) -> Observable<Chat> {
        return self.connectStream
    }
    
    func send(roomUID: String, chat: Chat) -> Observable<Void> {
        return self.sendEventStream
    }
    
    func masking(roomUID: String) -> Observable<String> {
        return self.maskingStream
    }

    func edit(roomUID: String, chat: Chat) -> Observable<Void> {
        return self.editStream
    }
    
    func getEditing(roomUID: String) -> Observable<Chat?> {
        return self.getEditStream
    }

}
