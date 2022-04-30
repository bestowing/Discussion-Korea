//
//  UsecaseProvider.swift
//  NetworkPlatform
//
//  Created by 이청수 on 2022/04/28.
//

import Domain

public final class UsecaseProvider: Domain.UsecaseProvider {

    private let networkProvider: NetworkProvider

    public init() {
        self.networkProvider = NetworkProvider()
    }

    public func makeChatsUsecase() -> Domain.ChatsUsecase {
        return ChatsUsecase(
            network: self.networkProvider.makeChatsNetwork()
        )
    }

}
