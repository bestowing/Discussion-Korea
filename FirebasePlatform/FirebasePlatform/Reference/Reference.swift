//
//  Reference.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Domain
import Foundation
import FirebaseDatabase
import RxSwift

final class Reference {

    private let reference: DatabaseReference

    init(reference: DatabaseReference) {
        self.reference = reference
    }

    func getChats() -> Observable<[Chat]> {
        Observable<[Chat]>.just([])
    }

    func save(chat: Chat) -> Observable<Void> {
        Observable<Void>.just(Void())
    }

}
