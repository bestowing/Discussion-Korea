//
//  ChatRoomCoverViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/13.
//

import Foundation
import RxCocoa

final class ChatRoomCoverViewModel: ViewModelType {

    // MARK: - properties

    private let uid: String
    private let chatRoom: ChatRoom
    private let navigator: ChatRoomCoverNavigator

    private let chatRoomsUsecase: ChatRoomsUsecase

    // MARK: - init/deinit
    
    init(uid: String,
         chatRoom: ChatRoom,
         navigator: ChatRoomCoverNavigator,
         chatRoomsUsecase: ChatRoomsUsecase) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.chatRoomsUsecase = chatRoomsUsecase
    }

     deinit {
        print("🗑", self)
    }

    func transform(input: Input) -> Output {

        let reportEvent = input.reportTrigger
            .map { [unowned self] _ in (self.uid, self.chatRoom.uid) }
            .do(onNext: self.navigator.toReport)
            .mapToVoid()

        let participateEvent = input.participateTrigger
            .flatMapFirst { [unowned self] _ in
                self.chatRoomsUsecase.participate(
                    userID: self.uid, chatRoomID: self.chatRoom.uid
                )
                .asDriverOnErrorJustComplete()
                .map { (self.uid, self.chatRoom) }
            }
            .do(onNext: self.navigator.toChatRoom)
            .mapToVoid()

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toChatRoomFind)

        let events = Driver.of(reportEvent, exitEvent, participateEvent).merge()

        return Output(
            title: Driver.just(self.chatRoom.title).asDriver(),
            profileURL: Driver.just(self.chatRoom.profileURL).asDriver(),
            events: events
        )
    }

}

extension ChatRoomCoverViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
        let reportTrigger: Driver<Void>
        let participateTrigger: Driver<Void>
    }

    struct Output {
        let title: Driver<String>
        let profileURL: Driver<URL?>
        let events: Driver<Void>
    }

}
