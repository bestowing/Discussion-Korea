//
//  ChatRoomScheduleViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import Foundation
import RxCocoa

final class ChatRoomScheduleViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String
    private let chatRoom: ChatRoom

    private let usecase: DiscussionUsecase
    private let navigator: ChatRoomScheduleNavigator

    // MARK: - init/deinit

    init(userID: String,
         chatRoom: ChatRoom,
         usecase: DiscussionUsecase,
         navigator: ChatRoomScheduleNavigator) {
        self.userID = userID
        self.chatRoom = chatRoom
        self.usecase = usecase
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let schedules = input.viewWillAppear
            .flatMap { [unowned self] in
                self.usecase.discussions(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .scan([ScheduleItemViewModel]()) { viewModels, discussion in
                        return viewModels + [ScheduleItemViewModel(with: discussion)]
                    }
            }

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toChatRoom)

        let addDiscussionEvent = input.addDiscussionTrigger
                .do(onNext: { [unowned self] in
                    self.navigator.toAddDiscussion(self.chatRoom)
                })

        return Output(
            addEnabled: Driver.just(self.chatRoom.adminUID == self.userID),
            schedules: schedules,
            exitEvent: exitEvent,
            addDiscussionEvent: addDiscussionEvent
        )
    }

}

extension ChatRoomScheduleViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let exitTrigger: Driver<Void>
        let addDiscussionTrigger: Driver<Void>
    }

    struct Output {
        let addEnabled: Driver<Bool>
        let schedules: Driver<[ScheduleItemViewModel]>
        let exitEvent: Driver<Void>
        let addDiscussionEvent: Driver<Void>
    }

}
