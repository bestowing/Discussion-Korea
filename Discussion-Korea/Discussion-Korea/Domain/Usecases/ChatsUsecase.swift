//
//  ChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Foundation
import RxSwift

protocol ChatsUsecase {

    func chats() -> Observable<[Chat]>
    func save(chat: Chat) -> Observable<Void>

}
