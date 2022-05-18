//
//  SummaryManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/18.
//

import FirebaseDatabase
import Foundation

final class SummaryManager {

    private var agreeContents: [[String]]
    private var disagreeContents: [[String]]

    private var agreeIndexes: [String: Int]
    private var disagreeIndexes: [String: Int]

    private let dateFormatter: DateFormatter

    init(dateFormatter: DateFormatter) {
        self.agreeContents = []
        self.disagreeContents = []
        self.agreeIndexes = [:]
        self.disagreeIndexes = [:]
        self.dateFormatter = dateFormatter
    }

    func connect(reference: DatabaseReference) {
        let now = Date()
        reference.observe(.childAdded) { [unowned self] snapshot in
            guard let dic = snapshot.value as? [String: Any],
                  let dateString = dic["date"] as? String,
                  let date = dateFormatter.date(from: dateString),
                  date > now,
                  let userID = dic["user"] as? String,
                  let content = dic["content"] as? String,
                  let sideString = dic["side"] as? String
            else { return }
            let chat = Chat(userID: userID, content: content)
            self.add(chat: chat, side: Side.toSide(from: sideString))
        }
    }

    private func add(chat: Chat, side: Side) {
        guard side == .agree || side == .disagree
        else { return }
        print(chat, "이 추가되었어요")
        let uid = chat.userID
        self.register(uid: uid, side: side)
        let content = chat.content
        if side == .agree {
            let index = self.agreeIndexes[uid]!
            self.agreeContents[index].append(content)
        } else {
            let index = self.disagreeIndexes[uid]!
            self.disagreeContents[index].append(content)
        }
    }

    func summaries(completion: @escaping ([[String]]) -> Void) {
        let agreeResult = self.agreeContents.map { $0.joined(separator: " ") }
        let disagreeResult = self.disagreeContents.map { $0.joined(separator: " ") }
        self.reset()
        print(agreeResult, disagreeResult)
        completion([agreeResult, disagreeResult])
    }

    /// 먼저 사용자를 등록해야함
    private func register(uid: String, side: Side) {
        // TODO: 이게 동시에 호출될 가능성이 없는지 확인해야함!! 만약 동시에 호출될 수 있으면 stream으로 바꿔주거나 동일 쓰레드에서만 실행되도록 하거나 lock을 써서 동기화해줘야함
        if side == .agree {
            if self.agreeIndexes[uid] == nil {
                self.agreeIndexes[uid] = self.agreeContents.count
                self.agreeContents.append([])
            }
        } else {
            if self.disagreeIndexes[uid] == nil {
                self.disagreeIndexes[uid] = self.disagreeContents.count
                self.disagreeContents.append([])
            }
        }
    }

    private func reset() {
        self.agreeContents = []
        self.disagreeContents = []
        self.agreeIndexes = [:]
        self.disagreeIndexes = [:]
    }

}
