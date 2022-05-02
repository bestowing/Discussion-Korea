//
//  ChatItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation

class ChatItemViewModel {

    let chat: Chat

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        return dateFormatter
    }()

    var timeString: String {
        guard let date = self.chat.date
        else { return "" }
        return self.dateFormatter.string(from: date)
    }

    var identifier: String {
        fatalError("not implemented")
    }

    init(with chat: Chat) {
        self.chat = chat
    }

}

final class SelfChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return SelfChatCell.identifier
    }

}

final class OtherChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return OtherChatCell.identifier
    }

}

final class SerialOtherChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return SerialOtherChatCell.identifier
    }

}
