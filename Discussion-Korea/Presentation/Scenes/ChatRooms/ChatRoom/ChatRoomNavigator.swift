//
//  ChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxSwift

enum DiscussionResult {
    case win
    case draw
    case lose
}

protocol ChatRoomNavigator {

    func toChatRoom(_ uid: String, _ chatRoom: ChatRoom)
    func toSideMenu(_ uid: String, _ chatRoom: ChatRoom)
    func toEnterAlert() -> Observable<Bool>
    func toSideAlert() -> Observable<Side>
    func toVoteAlert() -> Observable<Side>
    func toDiscussionResultAlert(result: DiscussionResult)
    func toOtherProfile(_ selfID: String, _ userID: String)

}
