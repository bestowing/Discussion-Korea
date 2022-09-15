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
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit
    
    init(uid: String,
         chatRoom: ChatRoom,
         navigator: ChatRoomCoverNavigator,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.chatRoomsUsecase = chatRoomsUsecase
        self.userInfoUsecase = userInfoUsecase
    }

     deinit {
        print("🗑", self)
    }

    func transform(input: Input) -> Output {

        let events = input.exitTrigger
            .do(onNext: self.navigator.toChatRoomFind)

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
