//
//  UserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxSwift

protocol UserInfoUsecase {

    func isValid(email: String) -> Observable<FormResult>
    func isValid(password: String) -> Observable<FormResult>
    func isValid(nickname: String) -> Observable<FormResult>
    func register(userInfo: (String, String)) -> Observable<Void>
    func signIn(userInfo: (email: String, password: String)) -> Observable<Void>
    func signOut() -> Observable<Void>
    func resetPassword(_ email: String) -> Observable<Void>

    func add(roomID: String, userID: String) -> Observable<Void>
    func add(roomID: String, userID: String, side: Side) -> Observable<Void>
    func add(userInfo: (String, String, Date?, URL?)) -> Observable<Void>
    func clearSide(roomID: String, userID: String) -> Observable<Void>
    func vote(roomID: String, userID: String, side: Side) -> Observable<Void>
    func userInfo(roomID: String, with userID: String) -> Observable<Side?>
    func userInfos(roomID: String) -> Observable<[String: UserInfo]>
    func userInfo(userID: String) -> Observable<UserInfo?>
    func support(side: Side, roomID: String, userID: String) -> Observable<Void>
    func supporter(roomID: String, userID: String) -> Observable<Side>

    func report(from userID: String, to victimID: String, reason: String) -> Observable<Void>
    func blockers(from userID: String) -> Observable<[String]>

}
