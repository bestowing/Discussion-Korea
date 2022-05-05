//
//  ChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class ChatRoomViewModel: ViewModelType {

    private let chatsUsecase: ChatsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let navigator: ChatRoomNavigator

    init(chatsUsecase: ChatsUsecase,
         userInfoUsecase: UserInfoUsecase,
         navigator: ChatRoomNavigator) {
        self.chatsUsecase = chatsUsecase
        self.userInfoUsecase = userInfoUsecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {

        let uid = self.userInfoUsecase
            .uid()
            .asDriverOnErrorJustComplete()

        let chats = input.trigger
            .withLatestFrom(uid)
            .flatMap { [unowned self] uid in
                self.chatsUsecase.connect(room: 1)
                    .asDriverOnErrorJustComplete()
                    .scan([ChatItemViewModel]()) { viewModels, chat in
                        let newItemViewModel: ChatItemViewModel
                        if let last = viewModels.last,
                           last.chat.userID == chat.userID,
                           let lastDate = last.chat.date,
                           let currentDate = chat.date,
                           Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                            viewModels.last?.chat.date = nil
                        }
                        if chat.userID == uid {
                            newItemViewModel = SelfChatItemViewModel(with: chat)
                        } else {
                            if let last = viewModels.last,
                               last.chat.userID == chat.userID {
                                newItemViewModel = SerialOtherChatItemViewModel(with: chat)
                            } else {
                                newItemViewModel = OtherChatItemViewModel(with: chat)
                            }
                        }
                        return viewModels + [newItemViewModel]
                    }
            }

        let canSend = input.content.map { !$0.isEmpty }

        let contentAndUID = Driver.combineLatest(input.content, uid)

        let sendEvent = input.send
            .withLatestFrom(contentAndUID)
            .map { (content, uid) -> Chat in
                Chat(userID: uid, content: content, date: Date())
            }
            .flatMap { [unowned self] in
                self.chatsUsecase.send(room: 1, chat: $0)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        return Output(chats: chats, sendEnable: canSend, sendEvent: sendEvent)
    }

}

extension ChatRoomViewModel {

    struct Input {
        let trigger: Driver<Void>
        let send: Driver<Void>
        let content: Driver<String>
    }
    
    struct Output {
        let chats: Driver<[ChatItemViewModel]>
        let sendEnable: Driver<Bool>
        let sendEvent: Driver<Void>
    }

}
