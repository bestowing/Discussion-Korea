//
//  UserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxSwift

protocol UserInfoUsecase {

    func add(roomID: String, userID: String) -> Observable<Void>
    func add(roomID: String, userID: String, side: Side) -> Observable<Void>
    func add(userInfo: (String, String, URL?)) -> Observable<Void>
    func clearSide(roomID: String, userID: String) -> Observable<Void>
    func vote(roomID: String, userID: String, side: Side) -> Observable<Void>
    func uid() -> Observable<String>
    func userInfo(roomID: String, with userID: String) -> Observable<Side?>
    func userInfos(roomID: String) -> Observable<[String: UserInfo]>
    func userInfo(userID: String) -> Observable<UserInfo?>
    func support(side: Side, roomID: String, userID: String) -> Observable<Void>
    func supporter(roomID: String, userID: String) -> Observable<Side>

}
