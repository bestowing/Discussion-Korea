//
//  ChatRoomSideMenuViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

import Foundation
import RxCocoa

final class ChatRoomSideMenuViewModel: ViewModelType {

    // MARK: properties

    private let chatRoom: ChatRoom

    private let userInfoUsecase: UserInfoUsecase
    private let navigator: ChatRoomSideMenuNavigator

    // MARK: - init/deinit

    init(chatRoom: ChatRoom,
         userInfoUsecase: UserInfoUsecase,
         navigator: ChatRoomSideMenuNavigator) {
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
            .flatMap { [unowned self] in
                self.userInfoUsecase.connect(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .scan([ParticipantItemViewModel]()) { viewModels, userInfo in
                        return viewModels + [ParticipantItemViewModel(with: userInfo)]
                    }
            }

        let calendarEvent = input.calendar
            .do(onNext: { [unowned self] in
                self.navigator.toChatRoomSchedule(self.chatRoom)
            })

        return Output(participants: participants, calendarEvent: calendarEvent)
    }

}

extension ChatRoomSideMenuViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let calendar: Driver<Void>
    }
    
    struct Output {
        let participants: Driver<[ParticipantItemViewModel]>
        let calendarEvent: Driver<Void>
    }

}
