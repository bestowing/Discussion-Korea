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

        let uid = userInfoUsecase.uid()
            .asDriverOnErrorJustComplete()

        let participants = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.connect(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .withLatestFrom(uid) { ($0, $1) }
                    .scan([ParticipantItemViewModel]()) { viewModels, args in
                        let userInfo = args.0
                        let uid = args.1
                        return viewModels + [ParticipantItemViewModel(with: userInfo, isSelf: uid == userInfo.uid)]
                    }
            }

        let calendarEvent = input.calendar
            .do(onNext: { [unowned self] in
                self.navigator.toChatRoomSchedule(self.chatRoom)
            })

        let chatRoomTitle = Driver.from([self.chatRoom.title])

        return Output(
            chatRoomTitle: chatRoomTitle,
            participants: participants,
            calendarEvent: calendarEvent
        )
    }

}

extension ChatRoomSideMenuViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let calendar: Driver<Void>
    }
    
    struct Output {
        let chatRoomTitle: Driver<String>
        let participants: Driver<[ParticipantItemViewModel]>
        let calendarEvent: Driver<Void>
    }

}
