//
//  Chat+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import FirebaseDatabase
import Foundation

extension Chat {

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
