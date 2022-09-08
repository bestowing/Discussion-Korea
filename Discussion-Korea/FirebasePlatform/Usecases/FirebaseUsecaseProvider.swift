//
//  FirebaseUsecaseProvider.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/29.
//

final class FirebaseUsecaseProvider: UsecaseProvider {

    private lazy var discussionBuilder = DiscussionBuilder()

    private let referenceProvider: ReferenceProvider

    init() {
        self.referenceProvider = ReferenceProvider()
    }

    func makeBuilderUsecase() -> BuilderUsecase {
        return IndependentBuilderUsecase(
            discussionBuilder: self.discussionBuilder
        )
    }

    func makeChatRoomsUsecase() -> ChatRoomsUsecase {
        return FirebaseChatRoomsUsecase(
            reference: self.referenceProvider.makeChatRoomsReference()
        )
    }

    func makeChatsUsecase() -> ChatsUsecase {
        return FirebaseChatsUsecase(
            reference: self.referenceProvider.makeChatsRefence()
        )
    }

    func makeDiscussionUsecase() -> DiscussionUsecase {
        return FirebaseDiscussionUsecase(
            reference: self.referenceProvider.makeDiscussionReference()
        )
    }

    func makeGuideUsecase() -> GuideUsecase {
        return FirebaseGuideUsecase(
            reference: self.referenceProvider.makeGuideReference()
        )
    }

    func makeLawUsecase() -> LawUsecase {
        return FirebaseLawUsecase(
            reference: self.referenceProvider.makeLawReference()
        )
    }

    func makeUserInfoUsecase() -> UserInfoUsecase {
        return FirebaseUserInfoUsecase(
            reference: self.referenceProvider.makeUserInfoReference()
        )
    }

}
