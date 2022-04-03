//
//  MessageRepository.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/18.
//

import Combine
import FirebaseDatabase
import Foundation

protocol MessageRepository {

    func checkIfFirstEntering() -> AnyPublisher<Bool, Never>
    func setNickname(by name: String)
    func observeUserInfo() -> AnyPublisher<UserInfo, Never>
    func observeChatMessage() -> AnyPublisher<Message, Never>
    func observeDetails() -> AnyPublisher<ChatRoomDetail, Never>
    func send(number: Int, message: Message)

}

class DefaultMessageRepository: MessageRepository {

    // MARK: properties

    private let messagesReference: DatabaseReference
    private let usersReference: DatabaseReference
    private let detailsReferece: DatabaseReference

    private let messagePublisher = PassthroughSubject<Message, Never>()
    private let userInfoPublisher = PassthroughSubject<UserInfo, Never>()
    private let detailPublisher = PassthroughSubject<ChatRoomDetail, Never>()
    private let dateFormatter: DateFormatter

    init(roomID: String) {
        let roomReference: DatabaseReference = Database
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
            .child("chatRoom")
            .child(roomID)
        self.messagesReference = roomReference.child("messages")
        self.usersReference = roomReference.child("users")
        self.detailsReferece = roomReference.child("details")
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

    func setNickname(by name: String) {
        // TODO: 이것도 중복되면 문제가...
        let values: [String: Any] = ["nickname": name]
        self.usersReference
            .child(IDManager.shared.userID())
            .setValue(values)
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

    func observeUserInfo() -> AnyPublisher<UserInfo, Never> {
        self.usersReference.observe(.childAdded) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? NSDictionary,
                  let nickname = dictionary["nickname"] as? String
            else { return }
            var newUserInfo = UserInfo(userID: snapshot.key, nickname: nickname)
            if let position = dictionary["position"] as? String {
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

    func send(number: Int, message: Message) {
        guard let date = message.date
        else { return }
        let values: [String: Any] = ["user": message.userID,
                                     "content": message.content,
                                     "date": self.dateFormatter.string(from: date)]
        self.messagesReference.runTransactionBlock { currentData in
            var messages = currentData.value as! [AnyObject]
            messages.append(values as AnyObject)
            currentData.value = messages
            return TransactionResult.success(withValue: currentData)
        }
    }

}
