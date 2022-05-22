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

    func chats(uid: String) -> Observable<[Chat]> {
        self.reference.getChats(uid: uid)
    }

    func connect(uid: String, after chatUID: String) -> Observable<Chat> {
        self.reference.receiveNewChats(uid: uid, afterUID: chatUID)
    }

    func send(room: Int, chat: Chat) -> Observable<Void> {
        self.reference.save(room: room, chat: chat)
    }

    func masking(uid: String) -> Observable<String> {
        self.reference.observeChatMasked(uid: uid)
    }

}
