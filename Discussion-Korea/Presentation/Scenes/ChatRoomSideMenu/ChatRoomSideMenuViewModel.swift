//
//  ChatRoomSideMenuViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomSideMenuViewModel: ViewModelType {

    // MARK: properties

    private let uid: String
    private let chatRoom: ChatRoom

    private let userInfoUsecase: UserInfoUsecase
    private let navigator: ChatRoomSideMenuNavigator

    // MARK: - init/deinit

    init(uid: String,
         chatRoom: ChatRoom,
         userInfoUsecase: UserInfoUsecase,
         navigator: ChatRoomSideMenuNavigator) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.userInfoUsecase = userInfoUsecase
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let participants = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.connect(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .scan([ParticipantItemViewModel]()) { viewModels, userInfo in
                        return viewModels + [ParticipantItemViewModel(with: userInfo, isSelf: self.uid == userInfo.uid)]
                    }
            }

        let calendarEvent = input.calendar
            .do(onNext: { [unowned self] in
                self.navigator.toChatRoomSchedule(self.chatRoom)
            })

        let chatRoomTitle = Driver.from([self.chatRoom.title])

        let sideEvent = input.side
            .flatMap { [unowned self] side in
                self.userInfoUsecase.support(side: side, roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let supportSide = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.supporter(roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let events = Driver.of(
            calendarEvent,
            sideEvent
        )
            .merge()

        return Output(
            chatRoomTitle: chatRoomTitle,
            selectedSide: supportSide,
            participants: participants,
            events: events
        )
    }

}

extension ChatRoomSideMenuViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let calendar: Driver<Void>
        let side: Driver<Side>
    }
    
    struct Output {
        let chatRoomTitle: Driver<String>
        let selectedSide: Driver<Side>
        let participants: Driver<[ParticipantItemViewModel]>
        let events: Driver<Void>
    }

}
