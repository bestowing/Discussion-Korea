//
//  DefaultChatItemViewModelFactory.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/05.
//

final class DefaultChatItemViewModelFactory: ChatItemViewModelFactory {

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
