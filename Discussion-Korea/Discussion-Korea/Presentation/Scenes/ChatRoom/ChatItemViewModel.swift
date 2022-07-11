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

    var backgroundColor: UIColor? {
        if let side = self.chat.side {
            switch side {
            case .agree:
                return UIColor(named: "agree")
            case .disagree:
                return UIColor(named: "disagree")
            default:
                break
            }
        }
        return nil
    }

    var textColor: UIColor? {
        if self.toxic {
            return .lightGray
        }
        return nil
    }

    var content: String {
        if self.toxic {
            return "⚠︎ 부적절한 내용이 감지되었습니다."
        }
        return self.chat.content
    }

    var image: UIImage? {
        if self.chat.userID == "bot" {
            return UIImage(named: "bot")
        }
        if self.chat.profileURL == nil {
            return UIImage(systemName: "person.fill")
        }
        return nil
    }

    var url: URL? {
        return self.chat.profileURL
    }

    var contentFont: UIFont {
        if self.toxic {
            return UIFont.systemFont(ofSize: 14.0)
        }
        return UIFont.systemFont(ofSize: 15.0)
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

    private var toxic: Bool {
        return self.chat.toxic ?? false
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

    override var textColor: UIColor? {
        if let textColor = super.textColor {
            return textColor
        }
        if self.chat.side == nil {
            return .white
        }
        return .label
    }

}

final class OtherChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return OtherChatCell.identifier
    }

    override var textColor: UIColor? {
        return super.textColor ?? UIColor.label
    }

}

final class WritingChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return WritingChatCell.identifier
    }

    override var textColor: UIColor? {
        return super.textColor ?? UIColor.label
    }

}

final class SerialOtherChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return SerialOtherChatCell.identifier
    }

    override var textColor: UIColor? {
        return super.textColor ?? UIColor.label
    }

}

final class BotChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return BotChatCell.identifier
    }

    override var textColor: UIColor? {
        return super.textColor ?? UIColor.label
    }

}

final class SerialBotChatItemViewModel: ChatItemViewModel {

    override var identifier: String {
        return SerialBotChatCell.identifier
    }

    override var textColor: UIColor? {
        return super.textColor ?? UIColor.label
    }

}
