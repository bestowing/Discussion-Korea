//
//  ChatRoomCoverNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/13.
//

protocol ChatRoomCoverNavigator {

    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom)
    func toChatRoom(_ userID: String, _ chatRoom: ChatRoom)
    func toChatRoomFind()
    func toReport(_ userID: String, _ reportedUID: String)

}
