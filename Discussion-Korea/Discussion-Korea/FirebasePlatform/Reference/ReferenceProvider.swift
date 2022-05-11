//
//  ReferenceProvider.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseDatabase

final class ReferenceProvider {

    private let reference: DatabaseReference

    init() {
        let urlString = "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app"
//        let localURLString = "http://localhost:9000?ns=test-3dbd4-default-rtdb"
        self.reference = Database
            .database(url: urlString)
            .reference()
    }

    func makeChatsRefence() -> Reference {
        Reference(reference: self.reference)
    }

    func makeUserInfoReference() -> Reference {
        Reference(reference: self.reference)
    }

    func makeDiscussionReference() -> Reference {
        Reference(reference: self.reference)
    }

}
