//
//  UsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

protocol UsecaseProvider {

    func makeChatRoomsUsecase() -> ChatRoomsUsecase
    func makeChatsUsecase() -> ChatsUsecase
    func makeDiscussionUsecase() -> DiscussionUsecase
    func makeUserInfoUsecase() -> UserInfoUsecase

}
