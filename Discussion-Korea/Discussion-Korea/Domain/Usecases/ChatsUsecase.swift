//
//  ChatsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Foundation
import RxSwift

public protocol ChatsUsecase {
    func chats() -> Observable<[]>
}
