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
    private let chatRoomsUsecase: ChatRoomsUsecase
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: ChatRoomListNavigator,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase) {
        self.navigator = navigator
        self.chatRoomsUsecase = chatRoomsUsecase
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let uid = self.userInfoUsecase
            .uid()
            .asDriverOnErrorJustComplete()

        let isGuest = uid
            .flatMapLatest { uid in
                self.userInfoUsecase.userInfo(userID: uid)
                    .asDriverOnErrorJustComplete()
            }
            .map { $0 == nil }

        let addChatRoomEvent = input.createChatRoomTrigger
            .withLatestFrom(isGuest)
            .filter { !$0 }
            .mapToVoid()
            .do(onNext: self.navigator.toAddChatRoom)

        let chatRooms = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatRoomsUsecase.chatRooms()
                    .asDriverOnErrorJustComplete()
            }

        let chatRoomItems = chatRooms
            .scan([ChatRoomItemViewModel]()) { (viewModels, chatRoom) in
                let viewModel = ChatRoomItemViewModel(chatRoom: chatRoom)
                return viewModels + [viewModel]
            }

        let enterEvent = input.selection
            .withLatestFrom(chatRoomItems) { (indexPath, chatRooms) -> ChatRoom in
                return chatRooms[indexPath.item].chatRoom
            }
            .do(onNext: self.navigator.toChatRoom)
            .mapToVoid()

        let events = Driver.of(enterEvent, addChatRoomEvent)
            .merge()

        return Output(chatRoomItems: chatRoomItems, events: events)
    }

}

extension ChatRoomListViewModel {

    struct Input {
        let trigger: Driver<Void>
        let selection: Driver<IndexPath>
        let createChatRoomTrigger: Driver<Void>
    }

    struct Output {
        let chatRoomItems: Driver<[ChatRoomItemViewModel]>
        let events: Driver<Void>
    }

}
