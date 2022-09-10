//
//  MyPageNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation

protocol ReadProfileNavigator {

    func toReadProfile(_ userID: String)
    func toSetting()
    func dismiss()
    func toReport()
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?)

}
