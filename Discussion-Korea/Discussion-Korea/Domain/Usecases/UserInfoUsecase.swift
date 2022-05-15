//
//  UserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxSwift

protocol UserInfoUsecase {

    func add(room: Int, userInfo: UserInfo) -> Observable<Void>
    func add(room: Int, uid: String, side: Side) -> Observable<Void>
    func vote(room: Int, uid: String, side: Side) -> Observable<Void>
    func uid() -> Observable<String>
    func userInfo(room: Int, with uid: String) -> Observable<UserInfo?>
    func connect(room: Int) -> Observable<UserInfo>

}
