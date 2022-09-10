//
//  ChatRoomSideMenuNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

protocol ChatRoomSideMenuNavigator {

    func toChatRoomSideMenu(_ uid: String, _ chatRoom: ChatRoom)
    func toChatRoomSchedule(_ userID: String, _ chatRoom: ChatRoom)
    func toOtherProfile(_ selfID: String, _ userID: String)

}
