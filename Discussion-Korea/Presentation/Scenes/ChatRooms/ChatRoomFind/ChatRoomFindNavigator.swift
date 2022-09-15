//
//  ChatRoomFindNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/15.
//

protocol ChatRoomFindNavigator {

    func toChatRoomFind(_ userID: String)
    func toChatRoomCover(_ chatRoom: ChatRoom)
    func toChatRoomList()

}
