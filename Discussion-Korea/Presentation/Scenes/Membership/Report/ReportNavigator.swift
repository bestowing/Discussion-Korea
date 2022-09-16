//
//  ReportNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

protocol ReportNavigator {

    func toReport(_ userID: String, _ reportedUID: String)
    func toChatRoomCover()
    func toChatRoomSideMenu()

}
