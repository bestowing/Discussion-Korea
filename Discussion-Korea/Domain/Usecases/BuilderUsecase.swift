//
//  BuilderUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import Foundation
import RxSwift

protocol BuilderUsecase {
    func setBasic(_ basic: (String, Date)) -> Observable<Void>
    func setDetail(_ detail: (Int, Int, Int, Bool)) -> Observable<Void>
    func getResult() -> Observable<Discussion?>
    func clear()
}
