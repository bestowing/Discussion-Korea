//
//  SideManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/16.
//

import Combine
import Foundation
import FirebaseDatabase

final class SideManager {

    private let chatRoomID: String

    init(chatRoomID: String) {
        self.chatRoomID = chatRoomID
    }

    @Published private var agrees: [String] = []
    @Published private var disagrees: [String] = []
    @Published private var judges: [String] = []
    @Published private var observers: [String] = []

    func isDone() -> AnyPublisher<Bool, Never> {
        self.$agrees
            .combineLatest($disagrees, $judges)
            .map {
                // FIXME: 판정단은 없어도 되는 상태
                return !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func appendAgree(id: String) {
        self.agrees.append(id)
    }

    func appendDisagree(id: String) {
        self.disagrees.append(id)
    }

    func appendJudge(id: String) {
        self.judges.append(id)
    }

    func appendObserver(id: String) {
        self.observers.append(id)
    }

    func agreeNicknames() -> [String] {
        return self.agrees.compactMap {
            return UserInfoManager.shared.userInfos[$0]?.nickname
        }
    }

    func disagreeNicknames() -> [String] {
        return self.disagrees.compactMap {
            return UserInfoManager.shared.userInfos[$0]?.nickname
        }
    }

    func endDiscussion() {
        self.agrees = []
        self.disagrees = []
        self.judges = []
        self.observers = []
    }

    func win(side: Side) {
        let reference = ReferenceManager.reference
        var updates = [String: Any]()
        let chatRoomID = self.chatRoomID
        self.agrees.forEach {
            updates["/chatRoom/\(chatRoomID)/users/\($0)/result"] = side == .agree ? "win" : "lose"
            updates["users/\($0)/\(side == .agree ? "win" : "lose")"] = 1
        }
        self.disagrees.forEach {
            updates["/chatRoom/\(chatRoomID)/users/\($0)/result"] = side == .agree ? "lose" : "win"
            updates["users/\($0)/\(side == .disagree ? "win" : "lose")"] = 1
        }
        reference.updateChildValues(updates)
    }

    func draw() {
        let reference = ReferenceManager.reference
        var updates = [String: Any]()
        self.agrees.forEach {
            updates["/chatRoom/\(chatRoomID)/users/\($0)/result"] = "draw"
            updates["users/\($0)/draw"] = 1
        }
        self.disagrees.forEach {
            updates["/chatRoom/\(chatRoomID)/users/\($0)/result"] = "draw"
            updates["users/\($0)/draw"] = 1
        }
        reference.updateChildValues(updates)
    }

}
