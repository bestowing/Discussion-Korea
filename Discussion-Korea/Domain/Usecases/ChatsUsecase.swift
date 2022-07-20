//
//  ChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxSwift

protocol ChatsUsecase {

    func chats(roomUID: String) -> Observable<[Chat]>
    func connect(roomUID: String, after chatUID: String?) -> Observable<Chat>
    func send(roomUID: String, chat: Chat) -> Observable<Void>
    func masking(roomUID: String) -> Observable<String>
    func edit(roomUID: String, chat: Chat) -> Observable<Void>
    func getEditing(roomUID: String) -> Observable<Chat>

}
