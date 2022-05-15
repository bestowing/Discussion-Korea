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

    func discussions(room: Int) -> Observable<Discussion> {
        self.reference.getDiscussions(room: room)
    }
    
    func add(room: Int, discussion: Discussion) -> Observable<Void> {
        self.reference.addDiscussion(room: room, discussion: discussion)
    }

    func status(room: Int) -> Observable<Int> {
        self.reference.getDiscussionStatus(room: room)
    }

    func remainTime(room: Int) -> Observable<Date> {
        self.reference.getDiscussionTime(room: room)
    }

}
