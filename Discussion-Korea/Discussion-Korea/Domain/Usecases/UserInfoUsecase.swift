//
//  UserInfoUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxSwift

public protocol UserInfoUsecase {

    func uid() -> Observable<String>
    func userInfo() -> Observable<UserInfo>

}
