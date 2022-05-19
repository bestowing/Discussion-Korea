//
//  ChatItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import UIKit

class ChatItemViewModel {

    // MARK: properties

    var chat: Chat

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

    var image: UIImage? {
        if self.chat.userID == "bot" {
            return UIImage(named: "bot")
        }
        return UIImage(systemName: "person.fill")
    }

    var nickname: String {
        if self.chat.userID == "bot" {
            return "방장봇"
        }
        return self.chat.nickName ?? self.chat.userID
    }

    var sideString: String {
        switch self.chat.side {
        case .agree:
            return " (찬성)"
        case .disagree:
            return " (반대)"
        default:
            return ""
        }
    }

    // MARK: - init/deinit

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
