//
//  ChatItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Differentiator
import UIKit

struct ChatItemViewModel {

    // MARK: - properties

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
        } else if self.isBlocked {
            return "⚠︎ 차단한 사용자의 채팅이에요."
        }
        return self.chat.content
    }

    var image: UIImage? {
        if self.chat.userID == "bot" {
            return UIImage(named: "bot")
        } else if self.isBlocked || self.chat.profileURL == nil {
            return UIImage(systemName: "person.fill")
        }
        return nil
    }

    var url: URL? {
        return self.chat.profileURL
    }

    var contentFont: UIFont {
        if self.toxic || self.isBlocked {
            return UIFont.preferredFont(forTextStyle: .footnote)
        }
        return UIFont.preferredFont(forTextStyle: .subheadline)
    }

    var nickname: String {
        if self.chat.userID == "bot" {
            return "방장봇"
        } else if self.isBlocked {
            return "차단한 사용자"
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

    private var isBlocked: Bool {
        return self.chat.isBlocked ?? false
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
