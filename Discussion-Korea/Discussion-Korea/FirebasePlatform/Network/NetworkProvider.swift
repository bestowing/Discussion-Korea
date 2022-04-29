//
//  NetworkProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/29.
//

import Foundation
import Domain

final class NetworkProvider {

    private let apiEndpoint: String

    init() {
        self.apiEndpoint = "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app"
    }

    func makeChatsNetwork() -> ChatsNetwork {
        let network = Network<Chat>(self.apiEndpoint)
        return ChatsNetwork(network: network)
    }

}
