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
    func send(number: Int, message: Message)

}

class DefaultMessageRepository: MessageRepository {

    // MARK: properties

    private let roomReference: DatabaseReference
    private let messagePublisher = PassthroughSubject<Message, Never>()
    private let userInfoPublisher = PassthroughSubject<UserInfo, Never>()
    private let dateFormatter: DateFormatter

    init() {
        self.roomReference = Database
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
            .child("chatRoom")
            .child("1")
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    // MARK: methods

    func checkIfFirstEntering() -> AnyPublisher<Bool, Never> {
        let futurePublisher = Future<Bool, Never>.init { [weak self] promise in
            // FIXME: 이런 문자열들도 DB에 넣으면 좋을텐데
            self?.roomReference
                .child("users")
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
        let values: [String: Any] = ["nickname": name]
        self.roomReference
            .child("users")
            .child(IDManager.shared.userID())
            .setValue(values)
    }

    func observeUserInfo() -> AnyPublisher<UserInfo, Never> {
        self.roomReference.child("users").observe(.childAdded) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? NSDictionary,
                  let nickname = dictionary["nickname"] as? String
            else { return }
            let newUserInfo = UserInfo(userID: snapshot.key, nickname: nickname)
            self?.userInfoPublisher.send(newUserInfo)
        }
        return self.userInfoPublisher.eraseToAnyPublisher()
    }

    func observeChatMessage() -> AnyPublisher<Message, Never> {
        self.roomReference.observe(.childAdded) { [weak self] snapshot in
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
        self.roomReference.child("\(number)").setValue(values)
    }

}
