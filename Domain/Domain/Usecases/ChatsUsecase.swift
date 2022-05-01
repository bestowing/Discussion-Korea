//
//  ChatsUsecase.swift
//  Domain
//
//  Created by 이청수 on 2022/04/29.
//

import RxSwift

public protocol ChatsUsecase {

    func chats(room: Int) -> Observable<[Chat]>
    func connect(room: Int) -> Observable<Chat>
    // FIXME: 일단 Int로 했지만 String으로 할 생각도 있음
    func send(room: Int, chat: Chat) -> Observable<Void>

}
