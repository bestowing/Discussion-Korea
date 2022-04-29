//
//  UsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Domain

final class UsecaseProvider: Domain.UsecaseProvider {

    private let networkProvider: NetworkProvider

    init() {
        self.networkProvider = NetworkProvider()
    }

    func makeChatsUsecase() -> Domain.ChatsUsecase {
        return ChatsUsecase(
            network: self.networkProvider.makeChatsNetwork()
        )
    }

}
