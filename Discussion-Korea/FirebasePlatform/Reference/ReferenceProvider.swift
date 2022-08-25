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
        let storage = Storage.storage()

        #if DEBUG
        let database = Database.database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
        storage.useEmulator(withHost: "localhost", port: 9199)
        #else
        let database = Database.database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
        #endif

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.reference = Reference(
            reference: database.reference(),
            storageReference: storage.reference(),
            dateFormatter: dateFormatter
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
