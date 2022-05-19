//
//  ChatRoomsUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import RxSwift

protocol ChatRoomsUsecase {

    func chatRooms() -> Observable<ChatRoom>
    func create(title: String, adminUID: String) -> Observable<Void>

}
