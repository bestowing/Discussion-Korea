//
//  FirebaseChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/30.
//

import Foundation
import RxSwift

final class FirebaseChatsUsecase: ChatsUsecase {

    private let reference: ChatsReference

    init(reference: ChatsReference) {
        self.reference = reference
    }

    func chats(roomUID: String) -> Observable<[Chat]> {
        self.reference.chats(roomID: roomUID)
    }

    func connect(roomUID: String, after chatUID: String?) -> Observable<Chat> {
        self.reference.chats(roomID: roomUID, after: chatUID)
    }

    func send(roomUID: String, chat: Chat) -> Observable<Void> {
        self.reference.add(in: roomUID, chat: chat)
    }

    func masking(roomUID: String) -> Observable<String> {
        self.reference.observeChatMasked(roomID: roomUID)
    }

    func edit(roomUID: String, chat: Chat) -> Observable<Void> {
        self.reference.write(in: roomUID, chat: chat)
    }

    func getEditing(roomUID: String) -> Observable<Chat?> {
        self.reference.read(in: roomUID)
    }

}
