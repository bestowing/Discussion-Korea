//
//  Reference.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/05/02.
//

import FirebaseDatabase
import FirebaseStorage
import RxSwift

enum RefereceError: Error {

    case profileError

}

final class Reference {

    private let reference: DatabaseReference
    private let storageReference: StorageReference

    init(reference: DatabaseReference, storageReference: StorageReference) {
        self.reference = reference
        self.storageReference = storageReference
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

    func add(chatRoom: ChatRoom) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            guard let key = self.reference
                .child("chatRooms")
                .childByAutoId().key
            else {
                subscribe.onCompleted()
                return Disposables.create()
            }
            var values: [String: Any] = ["title": chatRoom.title, "adminUID": chatRoom.adminUID]
            let userValue: [String: Any] = ["position": "admin"]
            if let profileURL = chatRoom.profileURL {
                let ref = self.storageReference
                    .child("\(chatRoom.uid)/profile/\(profileURL.lastPathComponent)")
                ref.putFile(from: profileURL, metadata: nil) { metadata, error in
                    guard let _ = metadata,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.profileError)
                        return
                    }
                    ref.downloadURL() { url, error in
                        guard let url = url,
                              error == nil
                        else {
                            subscribe.onError(RefereceError.profileError)
                            return
                        }
                        values["profile"] = url.absoluteString
                        let childUpdates: [String: Any] = [
                            "/chatRooms/\(key)": values,
                            "/chatRoom/\(key)/users/\(chatRoom.adminUID)": userValue,
                            "/chatRoom/\(key)/phase/value": 0
                        ]
                        self.reference.updateChildValues(childUpdates)
                        subscribe.onNext(())
                        subscribe.onCompleted()
                    }
                }
            } else {
                let childUpdates: [String: Any] = [
                    "/chatRooms/\(key)": values,
                    "/chatRoom/\(key)/users/\(chatRoom.adminUID)": userValue,
                    "/chatRoom/\(key)/phase/value": 0
                ]
                self.reference.updateChildValues(childUpdates)
                subscribe.onNext(())
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
    }

    func latestChat(chatRoomID: String) -> Observable<Chat> {
        return Observable.create { [unowned self] subscribe in
            var lastChat: Chat?
            self.reference
                .child("chatRoom/\(chatRoomID)/messages")
                .queryLimited(toLast: 1)
                .observeSingleEvent(of: .value) { snapshot in
                    if let chat = snapshot.children.compactMap({ child -> Chat? in
                        guard let snapshot = child as? DataSnapshot
                        else { return nil }
                        return Chat.toChat(from: snapshot)
                    }).first {
                        subscribe.onNext(chat)
                        lastChat = chat
                    }
                    if let afterUID = lastChat?.uid {
                        self.reference
                            .child("chatRoom/\(chatRoomID)/messages")
                            .queryOrderedByKey()
                            .queryStarting(afterValue: afterUID)
                            .observe(.childAdded) { snapshot in
                                guard let chat = Chat.toChat(from: snapshot)
                                else { return }
                                subscribe.onNext(chat)
                            }
                    } else {
                        self.reference
                            .child("chatRoom/\(chatRoomID)/messages")
                            .observe(.childAdded) { snapshot in
                                guard let chat = Chat.toChat(from: snapshot)
                                else { return }
                                subscribe.onNext(chat)
                            }
                    }
                }
            return Disposables.create()
        }
    }

    func numberOfUsers(chatRoomID: String) -> Observable<UInt> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(chatRoomID)/users")
                .observe(.value) { snapshot in
                    subscribe.onNext(snapshot.childrenCount)
                }
            return Disposables.create()
        }
    }

    func discussionResult(userID: String, chatRoomID: String) -> Observable<DiscussionResult> {
        // 최근 결과 느낌으로 해야할듯
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(chatRoomID)/users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let resultString = dictionary["result"] as? String
                    else { return }
                    switch resultString {
                    case "win":
                        subscribe.onNext(.win)
                    case "draw":
                        subscribe.onNext(.draw)
                    case "lose":
                        subscribe.onNext(.lose)
                    default:
                        break
                    }
                    self.clearResult(userID: userID, chatRoomID: chatRoomID)
                }
            return Disposables.create()
        }
    }

    private func clearResult(userID: String, chatRoomID: String) {
        self.reference
            .child("chatRoom/\(chatRoomID)/users/\(userID)/result")
            .setValue(nil)
        return
    }

    // MARK: - chats

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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var value: [String: Any] = ["user": chat.userID,
                    "content": chat.content,
                    "date": dateFormatter.string(from: date)]
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var value: [String: Any] = ["user": chat.userID,
                        "content": chat.content,
                        "date": dateFormatter.string(from: date)]
            if let side = chat.side {
                value["side"] = side.rawValue
            }
            let childUpdates = ["/chatRoom/\(roomID)/editing/\(chat.userID)": value]
            self.reference.updateChildValues(childUpdates)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func read(in roomID: String) -> Observable<Chat> {
        return Observable.create { [unowned self] subscribe in
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
            return Disposables.create()
        }
    }

    // MARK: - userInfos

    func userInfo(with userID: String) -> Observable<UserInfo?> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let nickname = dictionary["nickname"] as? String
                    else {
                        subscribe.onNext(nil)
                        return
                    }
                    var userInfo = UserInfo(uid: userID, nickname: nickname)
                    if let urlString = dictionary["profile"] as? String,
                       let url = URL(string: urlString) {
                        userInfo.profileURL = url
                    }
                    if let win = dictionary["win"] as? Int {
                        userInfo.win = win
                    }
                    if let draw = dictionary["draw"] as? Int {
                        userInfo.draw = draw
                    }
                    if let lose = dictionary["lose"] as? Int {
                        userInfo.lose = lose
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }
    }

    func userInfo(in roomID: String, with userID: String) -> Observable<UserInfo?> {
        return Observable<UserInfo?>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary
                    else {
                        subscribe.onNext(nil)
                        return
                    }
                    var userInfo = UserInfo(uid: userID, nickname: "")
                    if let sideString = dictionary["side"] as? String {
                        userInfo.side = Side.toSide(from: sideString)
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }
    }

    func userInfos(in roomID: String) -> Observable<UserInfo> {
        return Observable<UserInfo>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom").child("\(roomID)").child("users")
                .observe(.childAdded) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary
                    else { return }
                    var userInfo = UserInfo(uid: snapshot.key, nickname: "")
                    if let position = dic["position"] as? String {
                        userInfo.position = position
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }.flatMap { [unowned self] userInfo in
            return self.userInfoDetail(userInfo: userInfo)
        }
    }

    private func userInfoDetail(userInfo: UserInfo) -> Observable<UserInfo> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("users/\(userInfo.uid)")
                .observe(.value) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary,
                          let nickname = dic["nickname"] as? String
                    else { return }
                    let position = userInfo.position
                    var userInfo = UserInfo(uid: userInfo.uid, nickname: nickname)
                    userInfo.position = position
                    if let profile = dic["profile"] as? String,
                       let url = URL(string: profile) {
                        userInfo.profileURL = url
                    }
                    if let win = dic["win"] as? Int {
                        userInfo.win = win
                    }
                    if let draw = dic["draw"] as? Int {
                        userInfo.draw = draw
                    }
                    if let lose = dic["lose"] as? Int {
                        userInfo.lose = lose
                    }
                    subscribe.onNext(userInfo)
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    func add(userID: String, in roomID: String) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            let values: [String: Any] = ["position": "participant"]
            self.reference
                .child("chatRoom/\(roomID)/users")
                .child(userID)
                .setValue(values)
            subscribe.onNext(())
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func add(userInfo: UserInfo) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            var values: [String: Any] = [
                "nickname": userInfo.nickname,
                "win": 0,
                "draw": 0,
                "lose": 0
            ]
            if let profileURL = userInfo.profileURL {
                let ref = self.storageReference
                    .child("\(userInfo.uid)/profile/\(profileURL.lastPathComponent)")
                ref.putFile(from: profileURL, metadata: nil) { metadata, error in
                    guard let _ = metadata,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.profileError)
                        return
                    }
                    ref.downloadURL() { url, error in
                        guard let url = url,
                              error == nil
                        else {
                            subscribe.onError(RefereceError.profileError)
                            return
                        }
                        values["profile"] = url.absoluteString
                        self.reference.child("users/\(userInfo.uid)")
                            .setValue(values)
                        subscribe.onNext(())
                        subscribe.onCompleted()
                    }
                }
            } else {
                self.reference.child("users/\(userInfo.uid)")
                    .setValue(values)
                subscribe.onNext(())
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
    }

    func add(side: Side, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/sides/\(side.rawValue)")
                .updateChildValues([userID: true])
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)")
                .updateChildValues(["side": side.rawValue])
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func update(side: Side?, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)/side")
                .setValue(side)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func support(side: Side, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/supporters").runTransactionBlock { currentData in
                if let supporters = currentData.value as? [String: AnyObject] {
                    var newSupporters: [String: AnyObject] = [:]
                    let sides = [Side.agree, Side.disagree, Side.judge]
                    sides.forEach {
                        if $0 == side {
                            if var supporter = supporters[side.rawValue] as? [String] {
                                guard !supporter.contains(userID) else { return }
                                supporter.append(userID)
                                newSupporters[side.rawValue] = supporter as AnyObject
                            } else {
                                newSupporters[side.rawValue] = [userID] as AnyObject
                            }
                        } else {
                            guard var supporter = supporters[side.rawValue] as? [String],
                                  let index = supporter.firstIndex(of: userID) else { return }
                            supporter.remove(at: index)
                            newSupporters[side.rawValue] = supporter as AnyObject
                        }
                    }
                    currentData.value = newSupporters
                } else {
                    currentData.value = [side.rawValue: [userID]]
                }
                subscribe.onCompleted()
                return TransactionResult.success(withValue: currentData)
            }
            return Disposables.create()
        }
    }

    func supporters(in roomID: String) -> Observable<(String, Side)> {
        return Observable.create { [unowned self] subscribe in
            let sides = [Side.agree, .disagree, .judge]
            sides.forEach { side in
                self.reference.child("chatRoom/\(roomID)/supporters/\(side.rawValue)").observe(.childAdded) { snapshot in
                    guard let userID = snapshot.value as? String else { return }
                    subscribe.onNext((userID, side))
                }
            }
            return Disposables.create()
        }
    }

    func vote(roomID: String, userID: String, side: Side) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/votes/\(side.rawValue)").runTransactionBlock { currentData in
                if var votes = currentData.value as? [AnyObject] {
                    votes.append(userID as AnyObject)
                    currentData.value = votes
                } else {
                    currentData.value = [userID]
                }
                return TransactionResult.success(withValue: currentData)
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    // MARK: - discussions

    func getDiscussions(from roomID: String) -> Observable<Discussion> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Observable<Discussion>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/discussions")
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

    func add(_ discussion: Discussion, to roomID: String) -> Observable<Void> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let value: [String: Any] = ["date": dateFormatter.string(from: discussion.date),
                                    "durations": discussion.durations,
                                    "topic": discussion.topic]
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/discussions")
                .childByAutoId()
                .setValue(value)
            subscribe.onNext(Void())
            return Disposables.create()
        }
    }

    func getPhase(of roomID: String) -> Observable<Int> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/phase").observe(.childAdded) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            self.reference.child("chatRoom/\(roomID)/phase").observe(.childChanged) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            return Disposables.create()
        }
    }

    func getDiscussionTime(of roomID: String) -> Observable<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/endDate").observe(.childAdded) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            self.reference.child("chatRoom/\(roomID)/endDate").observe(.childChanged) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            return Disposables.create()
        }
    }

    func opinions(of roomID: String) -> Observable<(UInt, UInt)> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/supporters").observe(.value) { snapshot in
                guard let dictionary = snapshot.value as? NSDictionary
                else { return }
                let agree: UInt
                if let agrees = dictionary[Side.agree.rawValue] as? [String] {
                    agree = UInt(agrees.count)
                } else {
                    agree = 0
                }
                let disagree: UInt
                if let disagrees = dictionary[Side.disagree.rawValue] as? [String] {
                    disagree = UInt(disagrees.count)
                } else {
                    disagree = 0
                }
                subscribe.onNext((agree, disagree))
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
        var chatRoom = ChatRoom(
            uid: snapshot.key, title: title, adminUID: adminUID
        )
        if let profile = dic["profile"] as? String,
           let url = URL(string: profile) {
            chatRoom.profileURL = url
        }
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
