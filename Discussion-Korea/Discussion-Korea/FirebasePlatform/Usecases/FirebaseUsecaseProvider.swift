//
//  FirebaseUsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/29.
//

import Firebase

public final class FirebaseUsecaseProvider: UsecaseProvider {

    private let referenceProvider: ReferenceProvider

    public init() {
        FirebaseApp.configure()
        self.referenceProvider = ReferenceProvider()
    }

    public func makeChatsUsecase() -> ChatsUsecase {
        return FirebaseChatsUsecase(
            reference: self.referenceProvider.makeChatsRefence()
        )
    }

    public func makeUserInfoUsecase() -> UserInfoUsecase {
        return FirebaseUserInfoUsecase(
            reference: self.referenceProvider.makeUserInfoReference()
        )
    }

}
