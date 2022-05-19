//
//  FirebaseChatRoomsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import RxSwift
import Foundation

final class FirebaseChatRoomsUsecase: ChatRoomsUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func chatRooms() -> Observable<ChatRoom> {
        self.reference.chatRooms()
    }

    func create(title: String, adminUID: String) -> Observable<Void> {
        self.reference.addChatRoom(title: title, adminUID: adminUID)
    }

}
