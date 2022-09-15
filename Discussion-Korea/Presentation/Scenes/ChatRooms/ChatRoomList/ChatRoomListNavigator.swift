//
//  ChatRoomListNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

protocol ChatRoomListNavigator: AnyObject {

    func toChatRoomList(_ userID: String)
    func toChatRoom(_ userID: String, _ chatRoom: ChatRoom)
    func toChatRoomCover(_ userID: String, _ chatRoom: ChatRoom)
    func toAddChatRoom(_ userID: String)
    func toChatRoomFind(_ userID: String)

}
