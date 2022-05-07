//
//  ChatRoomSideMenuViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

import Foundation
import RxCocoa

final class ChatRoomSideMenuViewModel: ViewModelType {

    struct Input {
        let viewWillAppear: Driver<Void>
        let calendar: Driver<Void>
    }
    
    struct Output {
        let participants: Driver<[ParticipantItemViewModel]>
        let calendarEvent: Driver<Void>
    }

    // MARK: - properties

    private let userInfoUsecase: UserInfoUsecase
    private let navigator: ChatRoomSideMenuNavigator

    // MARK: - init/deinit

    init(userInfoUsecase: UserInfoUsecase, navigator: ChatRoomSideMenuNavigator) {
        self.userInfoUsecase = userInfoUsecase
        self.navigator = navigator
    }

    deinit {
        print(#function, self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let participants = input.viewWillAppear
            .flatMap { [unowned self] in
                self.userInfoUsecase.userInfo()
                    .asDriverOnErrorJustComplete()
                    .scan([ParticipantItemViewModel]()) {viewModels, userInfo in
                        return viewModels + [ParticipantItemViewModel(with: userInfo)]
                    }
            }

        let calendarEvent = input.calendar
            .do(onNext: self.navigator.toChatRoomSchedule)

        return Output(participants: participants, calendarEvent: calendarEvent)
    }

}
