//
//  ChatRoomsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import RxSwift

protocol ChatRoomsUsecase {

    func chatRooms(userID: String, participant: Bool) -> Observable<ChatRoom>
    func create(chatRoom: ChatRoom) -> Observable<Void>
    func latestChat(chatRoomID: String) -> Observable<Chat>
    func numberOfUsers(chatRoomID: String) -> Observable<UInt>
    func isFirstEntering(userID: String, chatRoomID: String) -> Observable<Bool>

}
