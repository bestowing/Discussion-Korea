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

    private let participant: Bool
    private let userID: String
    private let navigator: ChatRoomListNavigator
    private let chatRoomsUsecase: ChatRoomsUsecase
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(participant: Bool,
         userID: String,
         navigator: ChatRoomListNavigator,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase) {
        self.participant = participant
        self.userID = userID
        self.navigator = navigator
        self.chatRoomsUsecase = chatRoomsUsecase
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let chatRooms = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatRoomsUsecase.chatRooms(userID: self.userID, participant: self.participant)
                    .asDriverOnErrorJustComplete()
            }

        let chatRoomLatestChatContent = chatRooms
            .filter { [unowned self] _ in self.participant }
            .flatMap { [unowned self] chatRoom in
                self.chatRoomsUsecase.latestChat(chatRoomID: chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .map { (chatRoom.uid, $0) }
            }

        let chatRoomUsers = chatRooms
            .flatMap { [unowned self] chatRoom in
                self.chatRoomsUsecase.numberOfUsers(chatRoomID: chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .map { (chatRoom.uid, $0) }
            }

        let chatRoomItems = chatRooms
            .scan([ChatRoomItemViewModel]()) { (viewModels, chatRoom) in
                let viewModel = ChatRoomItemViewModel(chatRoom: chatRoom)
                return viewModels + [viewModel]
            }

        let chatRoomItemsWithInfos = Driver.combineLatest(chatRoomLatestChatContent.startWith(((""), Chat(userID: "", content: "", date: Date()))), chatRoomItems)
            .map { (args, models) -> [ChatRoomItemViewModel] in
                let uid = args.0
                let chat = args.1
                let model = models.first { $0.chatRoom.uid == uid }
                model?.latestChat = chat
                return models
            }

        let chatRoomItemsWithUserInfos = Driver.combineLatest(chatRoomUsers, chatRoomItemsWithInfos)
            .map { (args, models) -> [ChatRoomItemViewModel] in
                let uid = args.0
                let numbers = args.1
                let model = models.first { $0.chatRoom.uid == uid }
                model?.users = numbers
                return models
            }

        let addChatRoomEvent = input.createChatRoomTrigger
            .map { [unowned self] _ in self.userID }
            .do(onNext: self.navigator.toAddChatRoom)
            .mapToVoid()
                
        let findChatRoomEvent = input.findChatRoomTrigger
            .map { [unowned self] _ in self.userID  }
            .do(onNext: self.navigator.toChatRoomFind)
            .mapToVoid()

        let coverEvent = input.selection
            .withLatestFrom(chatRoomItems) { (indexPath, chatRooms) in
                return chatRooms[indexPath.item].chatRoom
            }
            .filter { [unowned self] _ in self.participant == false }
            .map { [unowned self] chatRoom in (self.userID, chatRoom) }
            .do(onNext: self.navigator.toChatRoomCover)
            .mapToVoid()

        let enterEvent = input.selection
            .withLatestFrom(chatRoomItems) { (indexPath, chatRooms) in
                return chatRooms[indexPath.item].chatRoom
            }
            .map { [unowned self] chatRoom in (self.userID, chatRoom) }
            .do(onNext: self.navigator.toChatRoom)
            .mapToVoid()

        let exitEvent = input.exitTrigger
            .map { [unowned self] _ in self.userID }
            .do(onNext: self.navigator.toChatRoomList)
            .mapToVoid()

        let events = Driver.of(
            enterEvent,
            coverEvent,
            addChatRoomEvent,
            findChatRoomEvent,
            exitEvent
        )
            .merge()

        return Output(chatRoomItems: chatRoomItemsWithUserInfos, events: events)
    }

}

extension ChatRoomListViewModel {

    struct Input {
        let trigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let selection: Driver<IndexPath>
        let createChatRoomTrigger: Driver<Void>
        let findChatRoomTrigger: Driver<Void>
    }

    struct Output {
        let chatRoomItems: Driver<[ChatRoomItemViewModel]>
        let events: Driver<Void>
    }

}
