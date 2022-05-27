//
//  ReferenceProvider.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseDatabase
import FirebaseStorage

final class ReferenceProvider {

    private let reference: Reference

    init() {
//        let urlString = "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app"
        let urlString = "http://localhost:9000?ns=test-3dbd4-default-rtdb"
//        let databaseReference = Database.database(url: urlString)
//            .reference()
        let database = Database.database(url: urlString)
        let storage = Storage.storage()
        storage.useEmulator(withHost: "localhost", port: 9199)
        self.reference = Reference(
            reference: database.reference(),
            storageReference: storage.reference()
        )
    }

    func makeChatRoomsReference() -> Reference {
        self.reference
    }

    func makeChatsRefence() -> Reference {
        self.reference
    }

    func makeUserInfoReference() -> Reference {
        self.reference
    }

    func makeDiscussionReference() -> Reference {
        self.reference
    }

}
