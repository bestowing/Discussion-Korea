//
//  ChatSectionModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/03.
//

import RxDataSources

struct ChatSectionModel {

    var header: String
    var items: [ChatItemViewModel]

    init(header: String, items: [ChatItemViewModel]) {
        self.header = header
        self.items = items
    }

}

extension ChatSectionModel: AnimatableSectionModelType {

    typealias Item = ChatItemViewModel
    typealias Identity = String

    var identity: String {
        return header
    }

    init(original: ChatSectionModel, items: [ChatItemViewModel]) {
        self = original
        self.items = items
    }

}
