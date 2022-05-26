//
//  Reference.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseDatabase
import RxSwift

final class Reference {

    private let reference: DatabaseReference

    init(reference: DatabaseReference) {
        self.reference = reference
    }

    // MARK: - chatRooms

    func chatRooms() -> Observable<ChatRoom> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRooms")
                .observe(.childAdded) { snapshot in
                    guard let chatRoom = ChatRoom.toChatRoom(from: snapshot)
                    else { return }
                    subscribe.onNext(chatRoom)
            }
            return Disposables.create()
        }
    }

    func addChatRoom(title: String, adminUID: String) -> Observable<Void> {
        let value: [String: Any] = ["title": title, "adminUID": adminUID]
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRooms")
                .childByAutoId().setValue(value)
            subscribe.onNext(Void())
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    // MARK: - chats

    func getChats(uid: String) -> Observable<[Chat]> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(uid)/messages")
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

    func receiveNewChats(uid: String, afterUID: String) -> Observable<Chat> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(uid)/messages")
                .queryOrderedByKey()
                .queryStarting(afterValue: afterUID)
                .observe(.childAdded) { snapshot in
                    guard let chat = Chat.toChat(from: snapshot)
                    else { return }
                    subscribe.onNext(chat)
                }
            return Disposables.create()
        }
    }

    func observeChatMasked(uid: String) -> Observable<String> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(uid)/messages")
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

    func save(uid: String, chat: Chat) -> Observable<Void> {
        // chatRoomViewModel에서 방 번호 혹은 아이디값을 가지고 있어야함
        // 여기서 번호를 부여하는게 아니라 걍 고유 아이디값으로 추가하면 안되나?
        guard let key = self.reference
            .child("chatRoom/\(uid)/messages")
            .childByAutoId().key,
              let date = chat.date
        else {
            return Observable<Void>.just(Void())
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var value: [String: Any] = ["user": chat.userID,
                    "content": chat.content,
                    "date": dateFormatter.string(from: date)]
        if let side = chat.side {
            value["side"] = side.rawValue
        }
        let childUpdates = ["/chatRoom/\(uid)/messages/\(key)": value]
        self.reference.updateChildValues(childUpdates)
        return Observable<Void>.just(Void())
    }

    // MARK: - userInfos

    func getUserInfo(in room: Int, with uid: String) -> Observable<UserInfo?> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/users/\(uid)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let nickname = dictionary["nickname"] as? String
                    else {
                        subscribe.onNext(nil)
                        return
                    }
                    var userInfo = UserInfo(uid: uid, nickname: nickname)
                    if let sideString = dictionary["side"] as? String {
                        userInfo.side = Side.toSide(from: sideString)
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }
    }

    func getUserInfo(room: Int) -> Observable<UserInfo> {
        return Observable<UserInfo>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom").child("\(room)").child("users")
                .observe(.childAdded) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary,
                          let nickname = dic["nickname"] as? String
                    else { return }
                    var userInfo = UserInfo(uid: snapshot.key, nickname: nickname)
                    if let urlString = dic["profile"] as? String,
                       let url = URL(string: urlString) {
                        userInfo.profileURL = url
                    }
                    if let position = dic["position"] as? String {
                        userInfo.position = position
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }
    }

    func addUserInfo(room: Int, userInfo: UserInfo) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            let values: [String: Any] = ["nickname": userInfo.nickname, "position": "방장"]
            self.reference
                .child("chatRoom/\(room)/users")
                .child(userInfo.uid)
                .setValue(values)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func setSide(room: Int, uid: String, side: Side) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/sides/\(side.rawValue)")
                .updateChildValues([uid: true])
            self.reference
                .child("chatRoom/\(room)/users/\(uid)")
                .updateChildValues(["side": side.rawValue])
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func clearSide(room: Int, uid: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/users/\(uid)/side")
                .setValue(nil)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func vote(room: Int, uid: String, side: Side) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(room)/votes/\(side.rawValue)").runTransactionBlock { currentData in
                if var votes = currentData.value as? [AnyObject] {
                    votes.append(uid as AnyObject)
                    currentData.value = votes
                } else {
                    currentData.value = [uid]
                }
                return TransactionResult.success(withValue: currentData)
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    // MARK: - discussions

    func getDiscussions(room: Int) -> Observable<Discussion> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Observable<Discussion>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/discussions")
                .observe(.childAdded) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary,
                          let dateString = dic["date"] as? String,
                          let date = dateFormatter.date(from: dateString),
                          let durations = dic["durations"] as? [Int],
                          let topic = dic["topic"] as? String
                    else { return }
                    let discussion = Discussion(uid: snapshot.key,
                                                date: date,
                                                durations: durations,
                                                topic: topic)
                    subscribe.onNext(discussion)
                }
            return Disposables.create()
        }
    }

    func addDiscussion(room: Int, discussion: Discussion) -> Observable<Void> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let value: [String: Any] = ["date": dateFormatter.string(from: discussion.date),
                                    "durations": discussion.durations,
                                    "topic": discussion.topic]
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/discussions")
                .childByAutoId()
                .setValue(value)
            subscribe.onNext(Void())
            return Disposables.create()
        }
    }

    func getDiscussionStatus(room: Int) -> Observable<Int> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(room)/phase").observe(.childAdded) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            self.reference.child("chatRoom/\(room)/phase").observe(.childChanged) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            return Disposables.create()
        }
    }

    func getDiscussionTime(room: Int) -> Observable<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(room)/endDate").observe(.childAdded) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            self.reference.child("chatRoom/\(room)/endDate").observe(.childChanged) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            return Disposables.create()
        }
    }

}

// 포지션 값도 키값으로 해야 할듯

fileprivate extension ChatRoom {

    static func toChatRoom(from snapshot: DataSnapshot) -> ChatRoom? {
        guard let dic = snapshot.value as? NSDictionary,
              let title = dic["title"] as? String,
              let adminUID = dic["adminUID"] as? String
        else { return nil }
        let chatRoom = ChatRoom(
            uid: snapshot.key, title: title, adminUID: adminUID
        )
        return chatRoom
    }

}

fileprivate extension Chat {

    static func toChat(from snapshot: DataSnapshot) -> Chat? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let dic = snapshot.value as? NSDictionary,
              let userID = dic["user"] as? String,
              let content = dic["content"] as? String,
              let dateString = dic["date"] as? String,
              let date = dateFormatter.date(from: dateString)
        else { return nil }
        var chat = Chat(userID: userID, content: content, date: date)
        chat.uid = snapshot.key
        if let sideString = dic["side"] as? String {
            let side = Side.toSide(from: sideString)
            chat.side = side
        }
        if let toxic = dic["toxic"] as? Bool {
            chat.toxic = toxic
        }
        return chat
    }

}
