//
//  ChatItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Differentiator
import Foundation
import UIKit

final class ChatItemViewModelFactory {

    enum CellIdentifier: String {
        case selfChat = "SelfChatCell"
        case serialBotChat = "SerialBotChatCell"
        case botChat = "BotChatCell"
        case otherChat = "OtherChatCell"
        case serialOtherChat = "SerialOtherChatCell"
        case writingChat = "WritingChatCell"

        var value: String {
            self.rawValue
        }
    }

    private let userID: String
    private let botID: String

    init(userID: String, botID: String = "bot") {
        self.userID = userID
        self.botID = botID
    }

    func create(prevChat: Chat?, chat: Chat, isEditing: Bool = false) -> ChatItemViewModel {
        guard !isEditing
        else {
            return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.writingChat.value)
        }
        if chat.userID == self.userID {
            return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.selfChat.value)
        } else if chat.userID == self.botID {
            if let prevChat = prevChat,
               prevChat.userID == chat.userID {
                return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.serialBotChat.value)
            }
            return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.botChat.value)
        }
        if let prevChat = prevChat,
           prevChat.userID == chat.userID {
            return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.serialOtherChat.value)
        }
        return ChatItemViewModel(with: chat, cellIdentifier: CellIdentifier.otherChat.value)
    }

}

struct ChatItemViewModel {

    // MARK: properties

    var chat: Chat
    let cellIdentifier: String

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
            return UIFont.preferredFont(forTextStyle: .footnote)
        }
        return UIFont.preferredFont(forTextStyle: .subheadline)
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

    init(with chat: Chat, cellIdentifier: String) {
        self.chat = chat
        self.cellIdentifier = cellIdentifier
    }

}

extension ChatItemViewModel: IdentifiableType, Equatable {

    typealias Identity = String

    var identity: Identity { self.chat.uid! }

    static func == (lhs: ChatItemViewModel, rhs: ChatItemViewModel) -> Bool {
        lhs.chat == rhs.chat
    }

}
