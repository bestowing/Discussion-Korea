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

    func getChats(room: Int) -> Observable<[Chat]> {
        Observable<[Chat]>.just([])
    }

    func receiveNewChats(room: Int) -> Observable<Chat> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return Observable<Chat>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(room)/messages")
                .observe(.childAdded) { snapshot in
                    guard let dic = snapshot.value as? [String: Any],
                          let userID = dic["user"] as? String,
                          let content = dic["content"] as? String,
                          let dateString = dic["date"] as? String,
                          let date = dateFormatter.date(from: dateString)
                    else { return }
                    subscribe.onNext(Chat(userID: userID, content: content, date: date))
                }
            return Disposables.create()
        }
    }

    func save(room: Int, chat: Chat) -> Observable<Void> {
        // chatRoomViewModel에서 방 번호 혹은 아이디값을 가지고 있어야함
        // 여기서 번호를 부여하는게 아니라 걍 고유 아이디값으로 추가하면 안되나?
        guard let key = self.reference
            .child("chatRoom").child("\(room)").child("messages")
            .childByAutoId().key,
              let date = chat.date
        else {
            return Observable<Void>.just(Void())
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let chat: [String: Any] = ["user": chat.userID,
                    "content": chat.content,
                    "date": dateFormatter.string(from: date)]
        let childUpdates = ["/chatRoom/\(room)/messages/\(key)": chat]
        self.reference.updateChildValues(childUpdates)
        return Observable<Void>.just(Void())
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

}

// 포지션 값도 키값으로 해야 할듯
