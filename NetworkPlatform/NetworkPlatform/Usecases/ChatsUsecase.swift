//
//  ChatsUsecase.swift
//  NetworkPlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Foundation
import RxSwift
import Domain

final class ChatsUsecase: Domain.ChatsUsecase {
    func send(room: Int, chat: Chat) -> Observable<Void> {
        return self.network.createChat(chat: chat)
            .map { _ in }
    }
    

    private let network: ChatsNetwork
//    private let cache: Cache<Chat>

//    init(network: ChatsNetwork, cache: Cache<Chat>) {
    init(network: ChatsNetwork) {
        self.network = network
//        self.cache = cache
    }

    func chats() -> Observable<[Chat]> {
//        let fetchChats = self.cache.fetchObjects().asObservable()
        let stored = self.network.fetchChats()
            .flatMap {
//                return self.cache.save(objects: $0)
//                    .asObservable()
//                    .map(to: [Chat].self)
//                    .concat(Observable.just($0))
                return Observable.just($0)
            }
        
        
        return stored
//        return fetchChats.concat(stored)
    }

}

struct MapFromNever: Error {}
extension ObservableType where Element == Never {
    func map<T>(to: T.Type) -> Observable<T> {
        return self.flatMap { _ in
            return Observable<T>.error(MapFromNever())
        }
    }
}
