//
//  MockDiscussionUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/21.
//

import Foundation
import RxSwift

final class MockDiscussionUsecase: DiscussionUsecase {

    // MARK: - properties

    var discussionStream: Observable<Discussion>
    var addRoomEventStream: Observable<Void>
    var statusStream: Observable<Int>
    var myRemainTimeStream: Observable<Date?>
    var remainTimeStream: Observable<Date>
    var discussionResultStream: Observable<DiscussionResult>
    var opinionsStream: Observable<(UInt, UInt)>

    // MARK: - init/deinit

    init() {
        self.discussionStream = PublishSubject<Discussion>.init()
        self.addRoomEventStream = PublishSubject<Void>.init()
        self.statusStream = PublishSubject<Int>.init()
        self.myRemainTimeStream = PublishSubject<Date?>.init()
        self.remainTimeStream = PublishSubject<Date>.init()
        self.discussionResultStream = PublishSubject<DiscussionResult>.init()
        self.opinionsStream = PublishSubject<(UInt, UInt)>.init()
    }

    // MARK: - methods

    func discussions(roomUID: String) -> Observable<Discussion> {
        return self.discussionStream
    }
    
    func add(roomUID: String, discussion: Discussion) -> Observable<Void> {
        return self.addRoomEventStream
    }
    
    func status(roomUID: String) -> Observable<Int> {
        return self.statusStream
    }

    func remainTime(userID: String, roomID: String) -> Observable<Date?> {
        return self.myRemainTimeStream
    }

    func remainTime(roomUID: String) -> Observable<Date> {
        return self.remainTimeStream
    }
    
    func discussionResult(userID: String, chatRoomID: String) -> Observable<DiscussionResult> {
        return self.discussionResultStream
    }

    func opinions(roomID: String) -> Observable<(UInt, UInt)> {
        return self.opinionsStream
    }

}
