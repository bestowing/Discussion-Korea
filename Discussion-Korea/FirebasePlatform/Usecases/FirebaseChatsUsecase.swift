//
//  FirebaseChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/30.
//

import Foundation
import RxSwift

final class FirebaseChatsUsecase: ChatsUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func chats(roomUID: String) -> Observable<[Chat]> {
        self.reference.getChats(uid: roomUID)
    }

    func connect(roomUID: String, after chatUID: String?) -> Observable<Chat> {
        self.reference.receiveNewChats(uid: roomUID, afterUID: chatUID)
    }

    func send(roomUID: String, chat: Chat) -> Observable<Void> {
        self.reference.save(uid: roomUID, chat: chat)
    }

    func masking(roomUID: String) -> Observable<String> {
        self.reference.observeChatMasked(uid: roomUID)
    }

    func edit(roomUID: String, chat: Chat) -> Observable<Void> {
        self.reference.edit(roomID: roomUID, chat: chat)
    }

    func getEditing(roomUID: String) -> Observable<Chat> {
        self.reference.getEdit(roomID: roomUID)
    }

}
