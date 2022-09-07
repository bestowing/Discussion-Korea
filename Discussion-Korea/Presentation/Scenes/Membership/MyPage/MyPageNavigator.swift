//
//  MyPageNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation

protocol MyPageNavigator {

    func toMyPage(_ userID: String)
    func toSetting()
    func toProfileEdit(_ userID: String, _ nickname: String?, profileURL: URL?)

}
