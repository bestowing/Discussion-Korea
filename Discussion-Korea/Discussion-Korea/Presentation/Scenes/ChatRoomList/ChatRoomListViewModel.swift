//
//  ChatRoomListViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation
import RxCocoa

final class ChatRoomListViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: ChatRoomListNavigator

    // MARK: - init/deinit

    init(navigator: ChatRoomListNavigator) {
        self.navigator = navigator
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        // FIXME: 방 식별자를 전달하도록 변경 필요
        let enterEvent = input.enterChatRoomTrigger
            .map { return "1" }
            .do(onNext: navigator.toChatRoom)
            .mapToVoid()

        let events = enterEvent

        return Output(events: events)
    }

}

extension ChatRoomListViewModel {

    struct Input {
        let enterChatRoomTrigger: Driver<Void>
    }

    struct Output {
        let events: Driver<Void>
    }

}
