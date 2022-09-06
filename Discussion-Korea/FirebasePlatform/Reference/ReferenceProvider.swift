//
//  ReferenceProvider.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseDatabase
import FirebaseStorage

final class ReferenceProvider {

    private let databaseReference: DatabaseReference
    private let storageReference: StorageReference

    private lazy var fullDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    private lazy var shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    init() {
        let storage = Storage.storage()

        #if DEBUG
        let database = Database.database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
        storage.useEmulator(withHost: "localhost", port: 9199)
        #else
        let database = Database.database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
        #endif

        self.databaseReference = database.reference()
        self.storageReference = storage.reference()
    }

    func makeChatRoomsReference() -> ChatRoomsReference {
        return ChatRoomsReference(
            reference: self.databaseReference,
            storageReference: self.storageReference
        )
    }

    func makeChatsRefence() -> ChatsReference {
        return ChatsReference(
            reference: self.databaseReference,
            dateFormatter: self.fullDateFormatter
        )
    }

    func makeDiscussionReference() -> DiscussionReference {
        return DiscussionReference(
            reference: self.databaseReference,
            dateFormatter: self.fullDateFormatter
        )
    }

    func makeGuideReference() -> GuideReference {
        return GuideReference(
            reference: self.databaseReference
        )
    }

    func makeUserInfoReference() -> UserInfoReference {
        return UserInfoReference(
            reference: self.databaseReference,
            storageReference: self.storageReference,
            dateFormatter: self.fullDateFormatter
        )
    }

    func makeLawReference() -> LawReference {
        return LawReference(
            reference: self.databaseReference,
            dateFormatter: self.shortDateFormatter
        )
    }

}
