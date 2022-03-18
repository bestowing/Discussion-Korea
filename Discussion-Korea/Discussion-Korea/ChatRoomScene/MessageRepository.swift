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

    func observe() -> AnyPublisher<Message, Never>
    func send(number: Int, message: Message)

}

class DefaultMessageRepository: MessageRepository {

    // MARK: properties

    private let roomReference: DatabaseReference
    private let messagePublisher = PassthroughSubject<Message, Never>()

    init() {
        self.roomReference = Database
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
            .child("chatRoom")
            .child("1")
    }

    // MARK: methods

    func observe() -> AnyPublisher<Message, Never> {
        self.roomReference.observe(.childAdded) { [weak self] snapshot in
            guard let dic = snapshot.value as? [String: Any],
                  let userID = dic["user"] as? String,
                  let content = dic["content"] as? String
            else { return }
            let newMessage = Message(userID: userID, content: content)
            self?.messagePublisher.send(newMessage)
        }
        return self.messagePublisher.eraseToAnyPublisher()
    }

    func send(number: Int, message: Message) {
        let values: [String: Any] = ["user": message.userID,
                                     "content": message.content]
        self.roomReference.child("\(number)").setValue(values)
    }

}
