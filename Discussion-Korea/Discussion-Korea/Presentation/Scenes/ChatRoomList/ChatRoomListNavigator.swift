//
//  ChatRoomListNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

protocol ChatRoomListNavigator {

    func toChatRoomList()
    func toChatRoom(_ uid: String, _ chatRoom: ChatRoom)
    func toAddChatRoom(_ userID: String)

}
