//
//  MessageRepository.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/18.
//

import Foundation

protocol MessageRepository {

    func send(message: String)

}

class DefaultMessageRepository: MessageRepository {

    func send(message: String) {
        // TODO: 구현 필요
    }

}
