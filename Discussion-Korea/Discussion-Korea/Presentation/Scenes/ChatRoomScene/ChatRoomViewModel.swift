//
//  ChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/30.
//

import Domain
import Foundation
import RxCocoa

final class ChatRoomViewModel: ViewModelType {

    private let usecase: Domain.ChatsUsecase
    private let navigator: ChatRoomNavigator

    init(usecase: Domain.ChatsUsecase, navigator: ChatRoomNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {

        let chats = input.trigger
            .flatMapLatest { [unowned self] in
                self.usecase.chats()
                    .asDriverOnErrorJustComplete()
                    .map { (chats) -> [ChatItemViewModel] in
                        zip(
                            [Chat(userID: "a", content: "a", date: Date())] + chats.dropLast(),
                            chats
                        ).map {
                            if $0.1.userID == IDManager.shared.userID() {
                                return SelfChatItemViewModel(with: $0.1)
                            } else {
                                if $0.0.userID == $0.1.userID {
                                    return OtherChatContItemViewModel(with: $0.1)
                                } else {
                                    return OtherChatItemViewModel(with: $0.1)
                                }
                            }
                        }
                    }
            }

        let canSend = input.content.map { !$0.isEmpty }

        let sendEvent = input.send.withLatestFrom(input.content)
            .map { Domain.Chat(userID: IDManager.shared.userID(), content: $0, date: Date()) }
            .flatMap { [unowned self] in
                self.usecase.send(room: 1, chat: $0)
                    .asDriverOnErrorJustComplete()
            }

        let events = sendEvent.mapToVoid()

        return Output(chats: chats, sendEnable: canSend, events: events)
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
        let events: Driver<Void>
    }

}
