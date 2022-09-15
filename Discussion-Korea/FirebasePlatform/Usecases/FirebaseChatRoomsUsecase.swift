//
//  FirebaseChatRoomsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import RxSwift
import Foundation

final class FirebaseChatRoomsUsecase: ChatRoomsUsecase {

    private let reference: ChatRoomsReference

    init(reference: ChatRoomsReference) {
        self.reference = reference
    }

    func chatRooms(userID: String, participant: Bool) -> Observable<ChatRoom> {
        self.reference.chatRooms(userID: userID, participant: participant)
    }

    func create(chatRoom: ChatRoom) -> Observable<Void> {
        self.reference.add(chatRoom: chatRoom)
    }

    func latestChat(chatRoomID: String) -> Observable<Chat> {
        self.reference.latestChat(chatRoomID: chatRoomID)
    }

    func numberOfUsers(chatRoomID: String) -> Observable<UInt> {
        self.reference.numberOfUsers(chatRoomID: chatRoomID)
    }

    func isFirstEntering(userID: String, chatRoomID: String) -> Observable<Bool> {
        self.reference.isFirstEntering(userID: userID, chatRoomID: chatRoomID)
    }

}
