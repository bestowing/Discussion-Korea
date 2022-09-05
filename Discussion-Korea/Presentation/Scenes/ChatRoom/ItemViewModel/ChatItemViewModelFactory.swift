//
//  ChatItemViewModelFactory.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/05.
//

protocol ChatItemViewModelFactory {
    func create(prevChat: Chat?, chat: Chat, isEditing: Bool) -> ChatItemViewModel
}
