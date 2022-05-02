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

    func chats(room: Int) -> Observable<[Chat]> {
        self.reference.getChats(room: room)
    }

    func connect(room: Int) -> Observable<Chat> {
        self.reference.receiveNewChats(room: room)
    }

    func send(room: Int, chat: Chat) -> Observable<Void> {
        self.reference.save(room: room, chat: chat)
    }

}
