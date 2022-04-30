//
//  UsecaseProvider.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Domain
import Firebase

public final class UsecaseProvider: Domain.UsecaseProvider {

    private let referenceProvider: ReferenceProvider

    public init() {
        FirebaseApp.configure()
        self.referenceProvider = ReferenceProvider()
    }

    public func makeChatsUsecase() -> Domain.ChatsUsecase {
        return ChatsUsecase(
            reference: self.referenceProvider.makeChatsRefence()
        )
    }

}
