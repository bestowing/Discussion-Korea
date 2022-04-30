//
//  ChatsUsecase.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/04/30.
//

import Foundation
import RxSwift
import Domain

final class ChatsUsecase: Domain.ChatsUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func chats() -> Observable<[Chat]> {
        self.reference.getChats()
    }

    func save(chat: Chat) -> Observable<Void> {
        self.reference.save(chat: chat)
    }

}
