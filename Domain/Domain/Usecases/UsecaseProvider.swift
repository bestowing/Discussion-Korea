//
//  UsecaseProvider.swift
//  Domain
//
//  Created by 이청수 on 2022/04/29.
//

public protocol UsecaseProvider {

    func makeChatsUsecase() -> ChatsUsecase

}
