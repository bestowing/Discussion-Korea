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
            .flatMapLatest { [unowned self] uid in
                self.chatsUsecase.chats(room: 1)
                    .asDriverOnErrorJustComplete()
                    .map { (chats) -> [ChatItemViewModel] in
                        zip(
                            [Chat(userID: "a", content: "a", date: Date())] + chats.dropLast(), chats
                        ).map {
                            if $0.1.userID == uid {
                                // 내가 보낸 메시지
                                return SelfChatItemViewModel(with: $0.1)
                            } else {
                                if $0.0.userID == $0.1.userID {
                                    // 같은 상대가 연속으로 보낸 메시지
                                    return SerialOtherChatItemViewModel(with: $0.1)
                                } else {
                                    // 상대방이 처음으로 보낸 메시지
                                    return OtherChatItemViewModel(with: $0.1)
                                }
                            }
                        }
                    }

            }

        let canSend = input.content.map { !$0.isEmpty }

        let contentAndUID = Driver.combineLatest(input.content, uid)

        let sendEvent = input.send.withLatestFrom(contentAndUID)
            .map { (content, uid) -> Chat in
                Chat(userID: uid, content: content, date: Date())
            }
            .flatMap { [unowned self] in
                self.chatsUsecase.send(room: 1, chat: $0)
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
