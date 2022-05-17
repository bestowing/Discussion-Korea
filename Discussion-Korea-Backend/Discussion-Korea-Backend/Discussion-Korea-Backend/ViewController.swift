//
//  ViewController.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/04/24.
//

import Combine
import UIKit

// 방 추가할때 phase 밑에 value(Int) 설정
// details 밑에 title(String)

final class ViewController: UIViewController {

    private let discussionManager: DiscussionManager = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return DiscussionManager(
            sideManager: SideManager(), dateFormatter: dateFormatter
        )
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.discussionManager.transform()
            .sink { _ in }
            .store(in: &self.cancellables)
//        let roomReference: DatabaseReference = Database
////            .database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
//            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
//            .reference()
//            .child("chatRoom")
//            .child("1")
//        self.messagesReference = roomReference.child("messages")
//        self.roomReference = roomReference
//        self.observeSides()
//        self.observeDiscussion()
    }

//    private func observeSides() {
//        self.roomReference?.child("sides").child("agree").observe(.childAdded) { [unowned self] snapshot in
//            self.sideManager.appendAgree(id: snapshot.key)
//        }
//        self.roomReference?.child("sides").child("disagree").observe(.childAdded) { [unowned self] snapshot in
//            self.sideManager.appendDisagree(id: snapshot.key)
//        }
//        self.roomReference?.child("sides").child("judge").observe(.childAdded) { [unowned self] snapshot in
//            self.sideManager.appendJudge(id: snapshot.key)
//        }
//        self.roomReference?.child("sides").child("observer").observe(.childAdded) { [unowned self] snapshot in
//            self.sideManager.appendObserver(id: snapshot.key)
//        }
//        self.sideManager.isDone().sink { [weak self] isDone in
//            if isDone {
//                self?.goPhaseTwo()
//            }
//        }.store(in: &self.cancellables)
//    }

//    private func observeDiscussion() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        self.roomReference?.child("discussions").observe(.childAdded) { [unowned self] snapshot in
//            guard let dic = snapshot.value as? NSDictionary,
//                  let dateString = dic["date"] as? String,
//                  let date = dateFormatter.date(from: dateString),
//                  let durations = dic["durations"] as? Array<Double>,
//                  let topic = dic["topic"] as? String
//            else { return }
//            let discussion = Discussion(
//                uid: snapshot.key, date: date, durations: durations, topic: topic
//            )
//            self.discussionManager.reserve(discussion: discussion)
//
//            // FIXME: 이 밑으로는 다 지워버리기
//            self.durations = durations
//
//            // 받은 그 순간에 바로 보내기
//            self.notifyDiscussionRegistered(topic: topic)
//
//            let currentDate = Date()
//
//            // 전날에 다시 보내기
//            let dateBeforeOneDay = Date(timeInterval: -86400, since: date)
//            if dateBeforeOneDay > currentDate {
//                let oneDayTimer = Timer(fireAt: dateBeforeOneDay, interval: 0, target: self, selector: #selector(notifyDiscussionBeforeOneDay), userInfo: nil, repeats: false)
//                RunLoop.main.add(oneDayTimer, forMode: .common)
//            }
//
//            // 1시간 전에 다시 보내기
//            let dateBeforeOneHour = Date(timeInterval: -60 * 60, since: date)
//            if dateBeforeOneHour > currentDate {
//                let oneHourTimer = Timer(fireAt: dateBeforeOneHour, interval: 0, target: self, selector: #selector(notifyDiscussionBeforeOneHour), userInfo: nil, repeats: false)
//                RunLoop.main.add(oneHourTimer, forMode: .common)
//            }
//
//            // 5분 전에 다시 보내기
//            let dateBeforeFiveMinutes = Date(timeInterval: -60 * 5, since: date)
//            if dateBeforeFiveMinutes > currentDate {
//                let fiveMinutesTimer = Timer(fireAt: dateBeforeFiveMinutes, interval: 0, target: self, selector: #selector(notifyDiscussionBeforeOneHour), userInfo: nil, repeats: false)
//                RunLoop.main.add(fiveMinutesTimer, forMode: .common)
//            }
//
//            // 당시에 다시 보내기
//            let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(notifyDiscussionStarting), userInfo: nil, repeats: false)
//
//            RunLoop.main.add(timer, forMode: .common)
//        }
//    }

//    private func notifyDiscussionRegistered(topic: String) {
//        self.send(message: Chat(userID: "bot",
//                                   content: "새로운 토론이 등록되었습니다. 주제는 \"\(topic)\"입니다.",
//                                   date: Date(),
//                                   nickName: nil))
//    }
//
//    @objc func notifyDiscussionBeforeOneDay() {
//        self.send(message: Chat(userID: "bot",
//                                   content: "토론 시작까지 하루 남았습니다",
//                                   date: Date(),
//                                   nickName: nil))
//    }
//
//    @objc func notifyDiscussionBeforeOneHour() {
//        self.send(message: Chat(userID: "bot",
//                                   content: "토론 시작까지 1시간 남았습니다",
//                                   date: Date(),
//                                   nickName: nil))
//    }
//
//    @objc func notifyDiscussionBeforeFiveMinutes() {
//        self.send(message: Chat(userID: "bot",
//                                   content: "토론 시작까지 5분 남았습니다",
//                                   date: Date(),
//                                   nickName: nil))
//    }
//
//    @objc func notifyDiscussionStarting() {
//        self.send(message: Chat(userID: "bot",
//                                   content: "예정된 토론 시간이 되었습니다. 찬성측, 반대측, 판정단이 최소 1명씩 배정되면 토론이 시작됩니다",
//                                   date: Date(),
//                                   nickName: nil))
//        self.send(phase: 1)
//    }

    

//    func send(message: Chat) {
//        guard let key = self.reference
//            .child("chatRoom/1/messages")
//            .childByAutoId().key,
//              let date = message.date
//        else { return }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let chat: [String: Any] = ["user": message.userID,
//                                   "content": message.content,
//                                   "date": dateFormatter.string(from: date)]
//        let childUpdates = ["/chatRoom/1/messages/\(key)": chat]
//        self.reference.updateChildValues(childUpdates)
//    }

//    func send(phase: Int) {
//        let value: [String: Any] = ["value": phase]
//        self.roomReference?.child("phase").setValue(value)
//    }

}
