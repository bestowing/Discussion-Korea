//
//  MessageRepository.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/18.
//

import Alamofire
import Combine
import FirebaseDatabase
import Foundation

enum Side: String {
    case agree = "agree"
    case disagree = "disagree"
    case judge = "judge"
    case observer = "observer"

    static func toSide(from string: String) -> Side {
        switch string {
        case "agree":
            return Side.agree
        case "disagree":
            return Side.disagree
        case "judge":
            return Side.judge
        default:
            return Side.observer
        }
    }

}

protocol MessageRepository {

    func checkIfFirstEntering() -> AnyPublisher<Bool, Never>
    func setInfo(name: String)
    func setInfo(side: Side)
    func observePhase() -> AnyPublisher<Int, Never>
    func observeUserInfo() -> AnyPublisher<UserInfo, Never>
    func observeChatMessage() -> AnyPublisher<Message, Never>
    func observeDetails() -> AnyPublisher<ChatRoomDetail, Never>
    func observeSchedules() -> AnyPublisher<DisscussionSchedule, Never>
    func send(number: Int, message: Message)
    func vote(side: Side)
    func addSchedule(_ schedule: DisscussionSchedule)
    func cancleSchedule(by scheduleID: String)

}

final class DefaultMessageRepository: MessageRepository {

    // MARK: properties

    private let messagesReference: DatabaseReference
    private let votesReference: DatabaseReference
    private let usersReference: DatabaseReference
    private let detailsReferece: DatabaseReference
    private let schedulesReferece: DatabaseReference
    private let phaseReferece: DatabaseReference
    private let sidesReferece: DatabaseReference

    private let messagePublisher = PassthroughSubject<Message, Never>()
    private let userInfoPublisher = PassthroughSubject<UserInfo, Never>()
    private let detailPublisher = PassthroughSubject<ChatRoomDetail, Never>()
    private let schedulePublisher = PassthroughSubject<DisscussionSchedule, Never>()
    private let phasePublisher = PassthroughSubject<Int, Never>()
    private let dateFormatter: DateFormatter

    init(roomID: String) {
        let roomReference: DatabaseReference = Database
//            .database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
            .child("chatRoom")
            .child(roomID)
        self.messagesReference = roomReference.child("messages")
        self.votesReference = roomReference.child("votes")
        self.usersReference = roomReference.child("users")
        self.detailsReferece = roomReference.child("details")
        self.schedulesReferece = roomReference.child("schedules")
        self.phaseReferece = roomReference.child("phase")
        self.sidesReferece = roomReference.child("sides")
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    // MARK: methods

    func checkIfFirstEntering() -> AnyPublisher<Bool, Never> {
        let futurePublisher = Future<Bool, Never>.init { [weak self] promise in
            // FIXME: 이런 문자열들도 DB에 넣으면 좋을텐데
            // TODO: 관찰하는걸로 바꾸기
            self?.usersReference
                .child(IDManager.shared.userID())
                .observeSingleEvent(of: .value, with: { snapshot in
                    let dictionary = snapshot.value as? NSDictionary
                    let nickname = dictionary?["nickname"] as? String
                    promise(.success(nickname == nil))
                })
        }
        return futurePublisher.eraseToAnyPublisher()
    }

    func setInfo(name: String) {
        // TODO: 이것도 중복되면 문제가...
        let values: [String: Any] = ["nickname": name, "position": "방장"]
        self.usersReference
            .child(IDManager.shared.userID())
            .setValue(values)
    }

    func setInfo(side: Side) {
        // TODO: 이것도 중복되면 문제가...
        self.sidesReferece
            .child(side.rawValue)
            .updateChildValues([IDManager.shared.userID(): true])
        self.usersReference
            .child(IDManager.shared.userID())
            .updateChildValues(["side": side.rawValue])
    }

    func observeDetails() -> AnyPublisher<ChatRoomDetail, Never> {
        self.detailsReferece.observe(.value) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? NSDictionary,
                  let title = dictionary["title"] as? String
            else { return }
            self?.detailPublisher.send(ChatRoomDetail(title: title))
        }
        return self.detailPublisher.eraseToAnyPublisher()
    }

    func observePhase() -> AnyPublisher<Int, Never> {
        self.phaseReferece.observe(.childAdded) { [weak self] snapshot in
            guard let phase = snapshot.value as? Int
            else { return }
            self?.phasePublisher.send(phase)
        }
        self.phaseReferece.observe(.childChanged) { [weak self] snapshot in
            guard let phase = snapshot.value as? Int
            else { return }
            self?.phasePublisher.send(phase)
        }
        return self.phasePublisher.eraseToAnyPublisher()
    }

    func observeUserInfo() -> AnyPublisher<UserInfo, Never> {
        self.usersReference.observe(.childAdded) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? NSDictionary,
                  let nickname = dictionary["nickname"] as? String
            else { return }
            var newUserInfo = UserInfo(userID: snapshot.key, nickname: nickname, isAdmin: false)
            if let position = dictionary["position"] as? String {
                if position == "방장" {
                    newUserInfo.isAdmin = true
                }
                newUserInfo.description = position
            }
            if newUserInfo.userID == IDManager.shared.userID() {
                if let description = newUserInfo.description {
                    newUserInfo.description = description + ", 나"
                } else {
                    newUserInfo.description = "나"
                }
            }
            self?.userInfoPublisher.send(newUserInfo)
        }
        return self.userInfoPublisher.eraseToAnyPublisher()
    }

    func observeChatMessage() -> AnyPublisher<Message, Never> {
        self.messagesReference.observe(.childAdded) { [weak self] snapshot in
            guard let dic = snapshot.value as? [String: Any],
                  let userID = dic["user"] as? String,
                  let content = dic["content"] as? String,
                  let dateString = dic["date"] as? String,
                  let date = self?.dateFormatter.date(from: dateString)
            else { return }
            let newMessage = Message(userID: userID, content: content, date: date)
            self?.messagePublisher.send(newMessage)
        }
        return self.messagePublisher.eraseToAnyPublisher()
    }

    func observeSchedules() -> AnyPublisher<DisscussionSchedule, Never> {
        self.schedulesReferece.observe(.childAdded) { [weak self] snapshot in
            guard let dic = snapshot.value as? NSDictionary,
                  let dateString = dic["date"] as? String,
                  let date = self?.dateFormatter.date(from: dateString),
                  let introduction = dic["introduction"] as? Int,
                  let main = dic["main"] as? Int,
                  let conclusion = dic["conclusion"] as? Int,
                  let topic = dic["topic"] as? String
            else { return }
            let scheduleID = snapshot.key
            self?.schedulePublisher.send(DisscussionSchedule(ID: scheduleID, date: date, introduction: introduction, main: main, conclusion: conclusion, topic: topic))
        }
        return self.schedulePublisher.eraseToAnyPublisher()
    }

    func vote(side: Side) {
        self.votesReference.child(side.rawValue).runTransactionBlock { currentData in
            if var votes = currentData.value as? [AnyObject] {
                votes.append(IDManager.shared.userID() as AnyObject)
                currentData.value = votes
            } else {
                currentData.value = [IDManager.shared.userID()]
            }
            return TransactionResult.success(withValue: currentData)
        }
    }

    func send(number: Int, message: Message) {
        guard let date = message.date
        else { return }
        let urlString = "http://119.194.17.59:8080/predictions/classification"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = ["text": message.content] as Dictionary
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print(error)
        }
        AF.request(request).responseString { [unowned self] response in
            switch response.result {
            case .success(let successMessage):
                let botID = "bot"
                let values: [String: Any] = ["user": message.userID,
                                             "content": message.content,
                                             "date": self.dateFormatter.string(from: date)]
                let botValue: [String: Any] = ["user": botID,
                                               "content": "\(message.nickName!)님, 비방성 표현 자제해주시기 바랍니다.",
                                               "date": self.dateFormatter.string(from: date)]
                self.messagesReference.runTransactionBlock { currentData in
                    if var messages = currentData.value as? [AnyObject] {
                        messages.append(values as AnyObject)
                        if successMessage == "toxic" {
                            messages.append(botValue as AnyObject)
                        }
                        currentData.value = messages
                    } else {
                        if successMessage == "toxic" {
                            currentData.value = [values, botValue]
                        } else {
                            currentData.value = [values]
                        }
                    }
                    return TransactionResult.success(withValue: currentData)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func addSchedule(_ schedule: DisscussionSchedule) {
        let value: [String: Any] = ["date": self.dateFormatter.string(from: schedule.date),
                                    "introduction": schedule.introduction,
                                    "main": schedule.main,
                                    "conclusion": schedule.conclusion,
                                    "topic": schedule.topic]
        self.schedulesReferece.childByAutoId().setValue(value)
    }

    func cancleSchedule(by scheduleID: String) {
        let value: [String: Any] = [:]
        self.schedulesReferece.child(scheduleID).setValue(value)
    }

}
