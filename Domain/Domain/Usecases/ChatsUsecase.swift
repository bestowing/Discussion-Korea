//
//  ChatsUsecase.swift
//  Domain
//
//  Created by 이청수 on 2022/04/29.
//

import RxSwift

public protocol ChatsUsecase {

    func chats() -> Observable<[Chat]>
    func save(chat: Chat) -> Observable<Void>

}
