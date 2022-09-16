//
//  MyPageNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation

protocol ReadProfileNavigator {

    func toReadProfile(_ selfID: String, _ userID: String)
    func toSetting()
    func dismiss()
    func toReport(_ userID: String, _ reportedUID: String)
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?)

}
