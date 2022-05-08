//
//  UsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

protocol UsecaseProvider {

    func makeChatsUsecase() -> ChatsUsecase
    func makeUserInfoUsecase() -> UserInfoUsecase
    func makeDiscussionUsecase() -> DiscussionUsecase

}
