//
//  ChatRoomScheduleViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import RxCocoa
import Foundation

final class ChatRoomScheduleViewModel: ViewModelType {

    // MARK: properties

    private let usecase: DiscussionUsecase
    private let navigator: ChatRoomScheduleNavigator

    // MARK: - init/deinit

    init(usecase: DiscussionUsecase,
         navigator: ChatRoomScheduleNavigator) {
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
                self.usecase.discussions(room: 1)
                    .asDriverOnErrorJustComplete()
                    .scan([ScheduleItemViewModel]()) { viewModels, discussion in
                        return viewModels + [ScheduleItemViewModel(with: discussion)]
                    }
            }

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toChatRoom)

        let addDiscussionEvent = input.addDiscussionTrigger
                .do(onNext: self.navigator.toAddDiscussion)

        return Output(schedules: schedules, exitEvent: exitEvent, addDiscussionEvent: addDiscussionEvent)
    }

}

extension ChatRoomScheduleViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let exitTrigger: Driver<Void>
        let addDiscussionTrigger: Driver<Void>
    }

    struct Output {
        let schedules: Driver<[ScheduleItemViewModel]>
        let exitEvent: Driver<Void>
        let addDiscussionEvent: Driver<Void>
    }

}
