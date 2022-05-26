//
//  FirebaseDiscussionUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxSwift

final class FirebaseDiscussionUsecase: DiscussionUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func discussions(roomUID: String) -> Observable<Discussion> {
        self.reference.getDiscussions(from: roomUID)
    }
    
    func add(roomUID: String, discussion: Discussion) -> Observable<Void> {
        self.reference.add(discussion, to: roomUID)
    }

    func status(roomUID: String) -> Observable<Int> {
        self.reference.getPhase(of: roomUID)
    }

    func remainTime(roomUID: String) -> Observable<Date> {
        self.reference.getDiscussionTime(of: roomUID)
    }

}
