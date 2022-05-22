//
//  ChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxSwift

protocol ChatsUsecase {

    func chats(uid: String) -> Observable<[Chat]>
    func connect(uid: String, after chatUID: String) -> Observable<Chat>
    func send(room: Int, chat: Chat) -> Observable<Void>
    func masking(uid: String) -> Observable<String>

}
