//
//  DiscussionManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/16.
//

import Combine
import FirebaseDatabase
import Foundation

/*
 phase 0: 평상시
 phase 1: 예약됨 - 찬성/반대 사람이 꽉 차지 않아서 대기중
 - 사람들한테 찬성 반대 고르도록 함
 - 찬성, 반대, 판정단이 1명씩 들어오면 phase를 2로 바꿈
 phase 2: 찬성측 입론 - 반대측은 발언 제한 (후반전일 경우 반대측 입론)
 phase 3: 반대측 입론 - 찬성측은 발언 제한 (후반전일 경우 찬성측 입론)
 phase 4: 자유토론
 phase 5: 찬성측 결론
 phase 6: 반대측 결론
 phase 7: 자유 시간 - 전반전일 경우 쉬는 시간 후 2번으로, 아니면 8번으로
 phase 8: 반대측 입론
 phase 9: 찬성측 입론
 phase 10: 자유토론
 phase 11: 반대측 결론
 phase 12: 찬성측 결론
 phase 13: 투표
 결과 발표 및 phase 0으로 회귀
*/

final class DiscussionManager {

    private let chatRoomID: String

    private let reference: DatabaseReference
    private let roomReference: DatabaseReference

    private let sideManager: SideManager
    private let summaryManager: SummaryManager
    private let dateFormatter: DateFormatter

    private var durations: [Double]

    private var isFirstHalf = true

    init(chatRoomID: String,
         sideManager: SideManager,
         dateFormatter: DateFormatter) {
        self.chatRoomID = chatRoomID
        self.reference = ReferenceManager.reference
        self.roomReference = self.reference.child("chatRoom/\(chatRoomID)")
        self.sideManager = sideManager
        self.summaryManager = SummaryManager(dateFormatter: dateFormatter, reference: self.roomReference.child("messages"))
        self.dateFormatter = dateFormatter
        self.durations = []
    }

    func transform() -> AnyPublisher<Void, Never> {
        self.observeDiscussion()
        self.observeSide()

        let maskingMessage = summaryManager.connect()
            .handleEvents(receiveOutput: { [unowned self] message in
                self.send(chat: Chat(userID: "bot", content: message, date: Date(), nickName: nil))
            })
            .map { _ in Void() }
            .eraseToAnyPublisher()

        let phaseTwoEvent = self.sideManager.isDone()
            .dropFirst()
            .handleEvents(receiveOutput: { [unowned self] ready in
                if ready {
                    let now = Date()
                    self.send(chat: Chat(
                        userID: "bot",
                        content: "찬성측, 반대측, 판정단이 최소 1명씩 배정되었습니다. 1분후 토론을 시작합니다. 토론에 참여하려면 빠르게 선택해주세요!",
                        date: now,
                        nickName: nil)
                    )
                    let end = Date(timeInterval: 60, since: now)
                    let timer = Timer(fireAt: end, interval: 0, target: self, selector: #selector(phaseFourEnd), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                    self.send(phase: 1, until: end)
                }
            })
            .map { _ in Void() }
            .eraseToAnyPublisher()

        let events = phaseTwoEvent
            .merge(with: maskingMessage)
            .eraseToAnyPublisher()

        return events
    }

    /// 새로운 토론이 추가되는 것을 관찰하고 처리한다
    private func observeDiscussion() {
        self.roomReference.child("discussions")
            .observe(.childAdded) { [unowned self] snapshot in
                guard let dic = snapshot.value as? NSDictionary,
                      let dateString = dic["date"] as? String,
                      let date = self.dateFormatter.date(from: dateString),
                      let durations = dic["durations"] as? Array<Double>,
                      let topic = dic["topic"] as? String
                else { return }
                let discussion = Discussion(
                    uid: snapshot.key, date: date, durations: durations, topic: topic
                )
                self.reserve(discussion: discussion)
            }
    }
    
    /// 토론 참가자가 진영을 선택하는 것을 관찰하고 처리한다
    private func observeSide() {
        self.roomReference.child("sides").child("agree").observe(.childAdded) { [unowned self] snapshot in
            self.sideManager.appendAgree(id: snapshot.key)
        }
        self.roomReference.child("sides").child("disagree").observe(.childAdded) { [unowned self] snapshot in
            self.sideManager.appendDisagree(id: snapshot.key)
        }
        self.roomReference.child("sides").child("judge").observe(.childAdded) { [unowned self] snapshot in
            self.sideManager.appendJudge(id: snapshot.key)
        }
        self.roomReference.child("sides").child("observer").observe(.childAdded) { [unowned self] snapshot in
            self.sideManager.appendObserver(id: snapshot.key)
        }
    }

    /// 새로운 토론을 예약한다
    private func reserve(discussion: Discussion) {
        let now = Date()
        guard discussion.date > now else { return }
        self.durations = discussion.durations
        self.send(chat: Chat(userID: "bot",
                             content: "새로운 토론이 등록되었습니다.\n주제는 \"\(discussion.topic)\"입니다.",
                             date: now,
                             nickName: nil))
        let dateBeforeOneDay = Date(timeInterval: -86400, since: discussion.date)
        if dateBeforeOneDay > now {
            let userInfo: [String: Any] = [
                "uid": "bot",
                "content": "토론 시작까지 하루 남았습니다",
                "date": dateBeforeOneDay
            ]
            let oneDayTimer = Timer(fireAt: dateBeforeOneDay, interval: 0, target: self, selector: #selector(notify), userInfo: userInfo, repeats: false)
            RunLoop.main.add(oneDayTimer, forMode: .common)
        }
        let dateBeforeOneHour = Date(timeInterval: -3600, since: discussion.date)
        if dateBeforeOneHour > now {
            let userInfo: [String: Any] = [
                "uid": "bot",
                "content": "토론 시작까지 1시간 남았습니다",
                "date": dateBeforeOneHour
            ]
            let oneHourTimer = Timer(fireAt: dateBeforeOneHour, interval: 0, target: self, selector: #selector(notify), userInfo: userInfo, repeats: false)
            RunLoop.main.add(oneHourTimer, forMode: .common)
        }
        let dateBeforeFiveMinutes = Date(timeInterval: -300, since: discussion.date)
        if dateBeforeFiveMinutes > now {
            let userInfo: [String: Any] = [
                "uid": "bot",
                "content": "토론 시작까지 5분 남았습니다",
                "date": dateBeforeFiveMinutes
            ]
            let oneHourTimer = Timer(fireAt: dateBeforeFiveMinutes, interval: 0, target: self, selector: #selector(notify), userInfo: userInfo, repeats: false)
            RunLoop.main.add(oneHourTimer, forMode: .common)
        }
        let userInfo: [String: Any] = [
            "uid": "bot",
            "content":
                "토론 주제는 \"\(discussion.topic)\"입니다. 찬성/반대/판정단을 선택해서 토론에 참여해주세요",
            "date": now
        ]
        let timer = Timer(
            fireAt: discussion.date,
            interval: 0,
            target: self,
            selector: #selector(notifyDiscussionStarting),
            userInfo: userInfo,
            repeats: false
        )
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func send(chat: Chat) {
        guard let key = self.roomReference
            .child("messages")
            .childByAutoId().key,
              let date = chat.date
        else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let chat: [String: Any] = ["user": chat.userID,
                                   "content": chat.content,
                                   "date": dateFormatter.string(from: date)]
        let childUpdates = ["/chatRoom/\(self.chatRoomID)/messages/\(key)": chat]
        self.reference.updateChildValues(childUpdates)
    }

    private func send(phase: Int) {
        let value: [String: Any] = ["value": phase]
        self.roomReference.child("phase")
            .setValue(value)
    }

    @objc private func notify(timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: Any],
              let uid = userInfo["uid"] as? String,
              let content = userInfo["content"] as? String,
              let date = userInfo["date"] as? Date
        else { return }
        self.send(chat: Chat(userID: uid,
                             content: content,
                             date: date,
                             nickName: nil))
    }

    @objc private func notifyDiscussionStarting(timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: Any],
              let uid = userInfo["uid"] as? String,
              let content = userInfo["content"] as? String,
              let date = userInfo["date"] as? Date
        else { return }
        self.send(chat: Chat(userID: uid,
                             content: content,
                             date: date,
                             nickName: nil))
        self.send(phase: 1)
    }
    
    private func goPhaseTwo(content: String) {
        let now = Date()
        // 누가 배정되었는지 소개하고 시작하기
        self.send(chat: Chat(userID: "bot",
                             content: content,
                             date: now,
                             nickName: nil))
        let agrees: [(String, String)] = self.sideManager.agreeNicknames()
        let disagrees: [(String, String)] = self.sideManager.disagreeNicknames()
        let totaltimeInterval = self.durations[0] * Double(60 * (self.isFirstHalf ? agrees.count : disagrees.count))
        let end = Date(timeInterval: totaltimeInterval, since: now)
        if self.isFirstHalf {
            self.send(chat: Chat(
                userID: "bot", content: "먼저 참가자를 소개하겠습니다. 찬성측에는 \(agrees.map { $0.1 + "님" }.joined(separator: ", "))이 토론에 참여해주셨습니다", date: now, nickName: nil)
            )
            self.send(chat: Chat(
                userID: "bot", content: "반대측에는 \(self.sideManager.disagreeNicknames().map { $0.1 + "님" }.joined(separator: ", "))이 토론에 참여해주셨습니다.", date: now, nickName: nil)
            )
            self.send(chat: Chat(userID: "bot", content: "그럼 먼저 찬성측 입론부터 듣겠습니다", date: now, nickName: nil))
            self.send(phase: 2, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: agrees, after: { [unowned self] in
                self.phaseTwoEnd()
            })
        } else {
            self.send(phase: 8, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: disagrees) { [unowned self] in
                self.phaseTwoEnd()
            }
        }
    }

    private func goPhaseThree(content: String) {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: content,
                             date: now,
                             nickName: nil))
        let agrees: [(String, String)] = self.sideManager.agreeNicknames()
        let disagrees: [(String, String)] = self.sideManager.disagreeNicknames()
        let totaltimeInterval = self.durations[0] * Double(60 * (self.isFirstHalf ? disagrees.count : agrees.count))
        let end = Date(timeInterval: totaltimeInterval, since: now)
        if self.isFirstHalf {
            self.send(phase: 3, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: disagrees) { [unowned self] in
                self.phaseThreeEnd()
            }
        } else {
            self.send(phase: 9, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: agrees) { [unowned self] in
                self.phaseThreeEnd()
            }
        }
    }

    private func goPhaseFour() {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: "지금부터 자유토론을 시작하겠습니다",
                             date: now,
                             nickName: nil))
        let timeInterval = self.durations[1] * 60
        let end = Date(timeInterval: timeInterval, since: now)
        let timer = Timer(fireAt: end, interval: 0, target: self, selector: #selector(phaseFourEnd), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        if self.isFirstHalf {
            self.send(phase: 4, until: end)
        } else {
            self.send(phase: 10, until: end)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: end)
        self.sideManager.agrees.forEach { [unowned self] in
            self.roomReference.child("speaker/\($0)").setValue(["value": dateString])
        }
        self.sideManager.disagrees.forEach { [unowned self] in
            self.roomReference.child("speaker/\($0)").setValue(["value": dateString])
        }
    }

    private func goPhaseFive(content: String) {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: content,
                             date: now,
                             nickName: nil))
        let agrees: [(String, String)] = self.sideManager.agreeNicknames()
        let disagrees: [(String, String)] = self.sideManager.disagreeNicknames()
        let totaltimeInterval = self.durations[0] * Double(60 * (self.isFirstHalf ? agrees.count : disagrees.count))
        let end = Date(timeInterval: totaltimeInterval, since: now)
        if self.isFirstHalf {
            self.send(phase: 5, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: agrees, after: { [unowned self] in
                self.phaseFiveEnd()
            })
        } else {
            self.send(phase: 11, until: end)
            self.giveRightSpeaking(start: now, end: end, userIDs: disagrees) { [unowned self] in
                self.phaseFiveEnd()
            }
        }
    }

    private func goPhaseSix(content: String) {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: content,
                             date: now,
                             nickName: nil))
        let agrees: [(String, String)] = self.sideManager.agreeNicknames()
        let disagrees: [(String, String)] = self.sideManager.disagreeNicknames()
        let totaltimeInterval = self.durations[0] * Double(60 * (self.isFirstHalf ? disagrees.count : agrees.count))
        let end = Date(timeInterval: totaltimeInterval, since: now)
        if self.isFirstHalf {
            self.send(phase: 6, until: end)
            let disagrees: [(String, String)] = self.sideManager.disagreeNicknames()
            self.giveRightSpeaking(start: now, end: end, userIDs: disagrees) { [unowned self] in
                self.phaseSixEnd()
            }
        } else {
            self.send(phase: 12, until: end)
            let agrees: [(String, String)] = self.sideManager.agreeNicknames()
            self.giveRightSpeaking(start: now, end: end, userIDs: agrees, after: { [unowned self] in
                self.phaseSixEnd()
            })
        }
    }

    /// 전후반 사이 쉬는 시간
    private func goPhaseSeven() {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: "전반전이 종료되었습니다. 잠시 쉬는 시간을 가지겠습니다.",
                             date: now,
                             nickName: nil))
        // FIXME: 쉬는 시간이 현재 1분임
        let timeInterval: TimeInterval = 1 * 60
        let end = Date(timeInterval: timeInterval, since: now)
        let timer = Timer(fireAt: end, interval: 0, target: self, selector: #selector(phaseSevenEnd), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.send(phase: 7, until: end)
        self.roomReference.child("speaker").setValue(nil)
    }

    private func goPhaseEight() {
        let now = Date()
        self.send(chat: Chat(userID: "bot",
                             content: "토론이 종료되었습니다. 판정단 여러분께서는 투표를 진행해주시기 바랍니다. 1분 안에 투표해주시길 바랍니다.",
                             date: now,
                             nickName: nil))
        let date = Date(timeInterval: 60 * 1, since: now) // 투표는 기본 1분간
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(votePhaseEnd), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.send(phase: 13, until: date)
        self.roomReference.child("speaker").setValue(nil)
    }

    private func endDiscussion() {
        self.send(chat: Chat(userID: "bot",
                             content: "판정단의 투표가 종료되었습니다. 투표를 집계하겠습니다...",
                             date: Date(),
                             nickName: nil))
        self.roomReference.child("votes").getData(completion: { [unowned self] error, snapshot in
            defer {
                self.send(phase: 0)
                self.sideManager.endDiscussion()
                self.isFirstHalf = true
                self.roomReference.child("supporters").setValue(nil)
                self.clean()
            }
            guard error == nil,
                  let dic = snapshot.value as? [String: Any]
            else {
                self.send(chat: Chat(userID: "bot",
                                     content: "치명적인 오류가 발생했습니다. 승리팀은 없습니다",
                                     date: Date(),
                                     nickName: nil))
                return
            }
            var agreeNumber = 0
            var disagreeNumber = 0
            if let agrees = dic["agree"] as? [Any] {
                agreeNumber = agrees.count
            }
            if let disagrees = dic["disagree"] as? [Any] {
                disagreeNumber = disagrees.count
            }
            if agreeNumber > disagreeNumber {
                self.sideManager.win(side: .agree)
                self.send(chat: Chat(userID: "bot",
                                     content: "찬성 팀이 이겼습니다!",
                                     date: Date(),
                                     nickName: nil))
            } else if agreeNumber < disagreeNumber {
                self.sideManager.win(side: .disagree)
                self.send(chat: Chat(userID: "bot",
                                     content: "반대 팀이 이겼습니다!",
                                     date: Date(),
                                     nickName: nil))
            } else {
                self.sideManager.draw()
                self.send(chat: Chat(userID: "bot",
                                     content: "무승부입니다!",
                                     date: Date(),
                                     nickName: nil))
            }
        })
    }
    
    private func clean() {
        self.reference.child("chatRoom/\(self.chatRoomID)/votes").setValue(nil)
        self.reference.child("chatRoom/\(self.chatRoomID)/sides").setValue(nil)
        self.reference.child("chatRoom/\(self.chatRoomID)/endDate").setValue(nil)
    }

    /// phase를 갱신할때 제한 시간이 있는 경우
    func send(phase: Int, until date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let value: [String: Any] = ["value": phase]
        let dateValue: [String: Any] = ["value": dateFormatter.string(from: date)]
        let childUpdates = ["/chatRoom/\(self.chatRoomID)/phase": value,
                            "/chatRoom/\(self.chatRoomID)/endDate": dateValue]
        self.reference.updateChildValues(childUpdates)
    }

    /// userIDs 배열에 있는 사용자들에게 start부터 end까지 발언권을 준다. 다 끝나면 phase로 이동
    func giveRightSpeaking(start: Date, end: Date, userIDs: [(String, String)], after excute: @escaping () -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        zip(stride(from: start, to: end, by: (self.durations[0] * 60)), userIDs).forEach { [unowned self] in
            let fireTime = $0.0
            let untilDate = $0.0 + self.durations[0] * 60
            let userID = $0.1.0
            let nickname = $0.1.1
            // $0.0까지 $0.1만 발언 가능함
            // 타이머를 예약해둠
            let timer = Timer(fire: fireTime, interval: 0, repeats: false, block: { [unowned self] _ in
                self.roomReference.child("editing").setValue(nil)
                self.roomReference.child("speaker").setValue(nil)
                self.send(chat: Chat(userID: "bot", content: "\(nickname)님의 말을 들어보겠습니다", date: fireTime, nickName: nil))
                self.roomReference.child("speaker/\(userID)")
                    .setValue(["value": dateFormatter.string(from: untilDate)])
            })
            RunLoop.main.add(timer, forMode: .common)
        }
        let timer = Timer(fire: end, interval: 0, repeats: false, block: { _ in
            excute()
        })
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc private func phaseOneEnd() {
        self.goPhaseTwo(content: "찬성측, 반대측, 판정단이 최소 1명씩 배정되어 토론을 시작합니다.")
    }

    @objc func phaseTwoEnd() {
        self.roomReference.child("editing").setValue(nil)
        if self.isFirstHalf {
            self.goPhaseThree(content: "이어서 반대측 입론을 듣겠습니다")
        } else {
            self.goPhaseThree(content: "이어서 찬성측 입론을 듣겠습니다")
        }
    }

    @objc func phaseThreeEnd() {
        self.roomReference.child("editing").setValue(nil)
        self.goPhaseFour()
    }

    @objc func phaseFourEnd() {
        self.roomReference.child("editing").setValue(nil)
        if self.isFirstHalf {
            self.goPhaseFive(content: "자유토론이 끝났습니다. 찬성측부터 결론을 말씀해주세요")
        } else {
            self.goPhaseFive(content: "자유토론이 끝났습니다. 반대측부터 결론을 말씀해주세요")
        }
    }

    @objc func phaseFiveEnd() {
        self.roomReference.child("editing").setValue(nil)
        if self.isFirstHalf {
            self.goPhaseSix(content: "반대측 결론 말씀해주세요")
        } else {
            self.goPhaseSix(content: "찬성측 결론 말씀해주세요")
        }
    }

    @objc func phaseSixEnd() {
        self.roomReference.child("editing").setValue(nil)
        self.send(phase: 7)
        if self.isFirstHalf {
            self.isFirstHalf = false
            let group = DispatchGroup()
            group.enter()
            group.enter()
            self.send(chat: Chat(userID: "bot", content: "양측의 발언을 요약하고 있습니다...", date: Date(), nickName: nil))
            self.summaryManager.summariesForAgree(completion: { [unowned self] results in
                results.forEach { uid, contents in
                    let nickname = UserInfoManager.shared.userInfos[uid]!.nickname
                    self.send(chat: Chat(userID: "bot", content: "찬성측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
                    self.send(chat: Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
                }
                group.leave()
            })
            self.summaryManager.summariesForDisAgree(completion: { [unowned self] results in
                results.forEach { uid, contents in
                    let nickname = UserInfoManager.shared.userInfos[uid]!.nickname
                    self.send(chat: Chat(userID: "bot", content: "반대측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
                    self.send(chat: Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
                }
                group.leave()
            })
            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) { [unowned self] in
                self.goPhaseSeven()
            }
        } else {
            let group = DispatchGroup()
            group.enter()
            group.enter()
            self.send(chat: Chat(userID: "bot", content: "양측의 발언을 요약하고 있습니다...", date: Date(), nickName: nil))
            self.summaryManager.summariesForAgree(completion: { [unowned self] results in
                results.forEach { uid, contents in
                    let nickname = UserInfoManager.shared.userInfos[uid]!.nickname
                    self.send(chat: Chat(userID: "bot", content: "찬성측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
                    self.send(chat: Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
                }
                group.leave()
            })
            self.summaryManager.summariesForDisAgree(completion: { [unowned self] results in
                results.forEach { uid, contents in
                    let nickname = UserInfoManager.shared.userInfos[uid]!.nickname
                    self.send(chat: Chat(userID: "bot", content: "반대측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
                    self.send(chat: Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
                }
                group.leave()
            })
            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) { [unowned self] in
                self.goPhaseEight()
            }
        }
    }

    @objc func phaseSevenEnd() {
        self.roomReference.child("editing").setValue(nil)
        self.goPhaseTwo(content: "쉬는 시간이 종료되었습니다. 이번에는 반대측 입론부터 듣겠습니다.")
    }

    @objc func votePhaseEnd() {
        self.endDiscussion()
    }

}

extension Date: Strideable {}
