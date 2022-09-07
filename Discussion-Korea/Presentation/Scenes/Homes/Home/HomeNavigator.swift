//
//  HomeNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

protocol HomeNavigator {

    func toHome(_ userID: String)
    func toChart()
    func toLaw()
    func toGuide()
    func toOnboarding(_ userID: String)

}
