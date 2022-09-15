//
//  ChatRoom+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import FirebaseDatabase
import Foundation

extension ChatRoom {

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

    static func isParticipant(from snapshot: DataSnapshot, userID: String) -> Bool {
        guard let dic = snapshot.value as? NSDictionary,
              let adminUID = dic["adminUID"] as? String
        else { return false }
        if adminUID == userID {
            return true
        }
        if let participants = dic["participants"] as? [String] {
            return participants.contains(userID)
        }
        return false
    }

}
