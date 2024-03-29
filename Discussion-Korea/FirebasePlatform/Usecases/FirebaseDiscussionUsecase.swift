//
//  FirebaseDiscussionUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxSwift

final class FirebaseDiscussionUsecase: DiscussionUsecase {

    private let reference: DiscussionReference

    init(reference: DiscussionReference) {
        self.reference = reference
    }

    func isValid(topic: String) -> Observable<FormResult> {
        return Observable.create { subscribe in
            if (1...60) ~= topic.count {
                subscribe.onNext(.success)
            } else {
                subscribe.onNext(.failure("1자 이상, 60자 이하로 입력해주세요"))
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
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

    func remainTime(userID: String, roomID: String) -> Observable<Date?> {
        self.reference.date(of: userID, in: roomID)
    }

    func remainTime(roomUID: String) -> Observable<Date> {
        self.reference.getDiscussionTime(of: roomUID)
    }

    func discussionResult(userID: String, chatRoomID: String) -> Observable<DiscussionResult> {
        // FIXME: 이게 채팅방 유즈케이스에 있는게 맞을까? 고민해보기
        self.reference.discussionResult(userID: userID, chatRoomID: chatRoomID)
    }

    func opinions(roomID: String) -> Observable<(UInt, UInt)> {
        self.reference.opinions(of: roomID)
    }

}
