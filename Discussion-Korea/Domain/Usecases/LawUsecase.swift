//
//  LawUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import RxSwift

protocol LawUsecase {

    func laws() -> Observable<[String]>

}
