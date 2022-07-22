//
//  DiscussionUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxSwift

protocol DiscussionUsecase {

    func discussions(roomUID: String) -> Observable<Discussion>
    func add(roomUID: String, discussion: Discussion) -> Observable<Void>
    func status(roomUID: String) -> Observable<Int>
    func remainTime(roomUID: String) -> Observable<Date>
    func discussionResult(userID: String, chatRoomID: String) -> Observable<DiscussionResult>
    func opinions(roomID: String) -> Observable<(UInt, UInt)>

}
