//
//  ChatsReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseDatabase
import RxSwift

final class ChatsReference {

    private let reference: DatabaseReference
    private let dateFormatter: DateFormatter

    init(reference: DatabaseReference, dateFormatter: DateFormatter) {
        self.reference = reference
        self.dateFormatter = dateFormatter
    }

    func chats(roomID: String) -> Observable<[Chat]> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/messages")
                .queryLimited(toLast: 30)
                .observeSingleEvent(of: .value) { snapshot in
                    let chats = snapshot.children.compactMap { child -> Chat? in
                        guard let snapshot = child as? DataSnapshot
                        else { return nil }
                        return Chat.toChat(from: snapshot)
                    }
                    subscribe.onNext(chats)
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    func chats(roomID: String, before chatUID: String) -> Observable<[Chat]> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/messages")
                .queryOrderedByKey()
                .queryEnding(beforeValue: chatUID)
                .queryLimited(toLast: 30)
                .observeSingleEvent(of: .value) { snapshot in
                    let chats = snapshot.children.compactMap { child -> Chat? in
                        guard let snapshot = child as? DataSnapshot
                        else { return nil }
                        return Chat.toChat(from: snapshot)
                    }
                    subscribe.onNext(chats)
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    func chats(roomID: String, after chatID: String?) -> Observable<Chat> {
        return Observable.create { [unowned self] subscribe in
            if let afterUID = chatID {
                self.reference
                    .child("chatRoom/\(roomID)/messages")
                    .queryOrderedByKey()
                    .queryStarting(afterValue: afterUID)
                    .observe(.childAdded) { snapshot in
                        guard let chat = Chat.toChat(from: snapshot)
                        else { return }
                        subscribe.onNext(chat)
                    }
            } else {
                self.reference
                    .child("chatRoom/\(roomID)/messages")
                    .observe(.childAdded) { snapshot in
                        guard let chat = Chat.toChat(from: snapshot)
                        else { return }
                        subscribe.onNext(chat)
                    }
            }
            return Disposables.create()
        }
    }

    func observeChatMasked(roomID: String) -> Observable<String> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/messages")
                .observe(.childChanged) { snapshot in
                    guard let dic = snapshot.value as? [String: Any],
                          let toxic = dic["toxic"] as? Bool,
                          toxic == true
                    else { return }
                    subscribe.onNext(snapshot.key)
                }
            return Disposables.create()
        }
    }

    func add(in roomID: String, chat: Chat) -> Observable<Void> {
        // chatRoomViewModel에서 방 번호 혹은 아이디값을 가지고 있어야함
        // 여기서 번호를 부여하는게 아니라 걍 고유 아이디값으로 추가하면 안되나?
        guard let key = self.reference
            .child("chatRoom/\(roomID)/messages")
            .childByAutoId().key,
              let date = chat.date
        else {
            return Observable<Void>.just(Void())
        }
        var value: [String: Any] = [
            "user": chat.userID,
            "content": chat.content,
            "date": self.dateFormatter.string(from: date)
        ]
        if let side = chat.side {
            value["side"] = side.rawValue
        }
        let childUpdates = ["/chatRoom/\(roomID)/messages/\(key)": value]
        self.reference.updateChildValues(childUpdates)
        return Observable<Void>.just(Void())
    }

    func write(in roomID: String, chat: Chat) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            guard let date = chat.date
            else { return Disposables.create() }
            var value: [String: Any] = [
                "user": chat.userID,
                "content": chat.content,
                "date": self.dateFormatter.string(from: date)
            ]
            if let side = chat.side {
                value["side"] = side.rawValue
            }
            let childUpdates = ["/chatRoom/\(roomID)/editing/\(chat.userID)": value]
            self.reference.updateChildValues(childUpdates)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func read(in roomID: String) -> Observable<Chat?> {
        return Observable.create { [unowned self] subscribe in
            subscribe.onNext(nil)
            self.reference
                .child("chatRoom/\(roomID)/editing")
                .observe(.childAdded) { snapshot in
                    guard let chat = Chat.toChat(from: snapshot)
                    else { return }
                    subscribe.onNext(chat)
                }
            self.reference
                .child("chatRoom/\(roomID)/editing")
                .observe(.childChanged) { snapshot in
                    guard let chat = Chat.toChat(from: snapshot)
                    else { return }
                    subscribe.onNext(chat)
                }
            self.reference
                .child("chatRoom/\(roomID)/editing")
                .observe(.childRemoved) { _ in
                    subscribe.onNext(nil)
                }
            return Disposables.create()
        }
    }

}
