//
//  Reference.swift
//  FirebasePlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Domain
import FirebaseDatabase
import RxSwift

final class Reference {

    private let reference: DatabaseReference

    init(reference: DatabaseReference) {
        self.reference = reference
    }

    func getChats(room: Int) -> Observable<[Chat]> {
        Observable<[Chat]>.just([Chat(userID: "123", content: "hello", date: Date()), Chat(userID: "123", content: "2", date: Date())])
    }

    func receiveNewChats(room: Int) -> Observable<Chat> {
        self.reference
            .child("\(room)/messages")
            .observe(.childAdded) { [weak self] snapshot in
                guard let dic = snapshot.value as? [String: Any],
                      let userID = dic["user"] as? String,
                      let content = dic["content"] as? String,
                      let dateString = dic["date"] as? String,
                      let date = self?.dateFormatter.date(from: dateString)
                else { return }
                
            }
    }

    func save(room: Int, chat: Chat) -> Observable<Void> {
        // chatRoomViewModel에서 방 번호 혹은 아이디값을 가지고 있어야함

        // 여기서 번호를 부여하는게 아니라 걍 고유 아이디값으로 추가하면 안되나?
        guard let key = self.reference
            .child("\(room)/messages")
            .childByAutoId().key,
              let date = chat.date
        else {
            return Observable<Void>.just(Void())
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let chat = ["user": chat.userID,
                    "content": chat.content,
                    "date": dateFormatter.string(from: date)]
        let childUpdates = ["/chatRoom/\(room)/messages/\(key)": chat]
        self.reference.updateChildValues(childUpdates)
        return Observable<Void>.just(Void())
    }

}
