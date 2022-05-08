//
//  FirebaseUsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/29.
//

import Firebase

final class FirebaseUsecaseProvider: UsecaseProvider {

    private let referenceProvider: ReferenceProvider

    init() {
        FirebaseApp.configure()
        self.referenceProvider = ReferenceProvider()
    }

    func makeChatsUsecase() -> ChatsUsecase {
        return FirebaseChatsUsecase(
            reference: self.referenceProvider.makeChatsRefence()
        )
    }

    func makeUserInfoUsecase() -> UserInfoUsecase {
        return FirebaseUserInfoUsecase(
            reference: self.referenceProvider.makeUserInfoReference()
        )
    }

    func makeDiscussionUsecase() -> DiscussionUsecase {
        return FirebaseDiscussionUsecase(
            reference: self.referenceProvider.makeDiscussionReference()
        )
    }

}
