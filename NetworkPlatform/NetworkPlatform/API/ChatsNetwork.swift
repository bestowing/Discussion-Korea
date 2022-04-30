//
//  ChatsNetwork.swift
//  NetworkPlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Domain
import RxSwift

final class ChatsNetwork {

    private let network: Network<Chat>

    init(network: Network<Chat>) {
        self.network = network
    }

    func fetchChats() -> Observable<[Chat]> {
        // FIXME: REST API path
        return self.network.getItems("chats")
    }

    func createChat(chat: Chat) -> Observable<Chat> {
        return self.network.postItem("chats", parameters: chat.toJSON())
    }

}
