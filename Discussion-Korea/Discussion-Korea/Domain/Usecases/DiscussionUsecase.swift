//
//  DiscussionUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxSwift

protocol DiscussionUsecase {

    func discussions(room: Int) -> Observable<Discussion>
    func add(room: Int, discussion: Discussion) -> Observable<Void>
    func status(room: Int) -> Observable<Int>
    func remainTime(room: Int) -> Observable<Date>

}
