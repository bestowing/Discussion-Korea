//
//  AddDiscussionViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxCocoa

final class AddDiscussionViewModel: ViewModelType {

    private let navigator: AddDiscussionNavigator
    private let usecase: DiscussionUsecase

    init(navigator: AddDiscussionNavigator, usecase: DiscussionUsecase) {
        self.navigator = navigator
        self.usecase = usecase
    }

    struct Input {
        let exitTrigger: Driver<Void>
        let title: Driver<String>
        let introTime: Driver<Int>
        let mainTime: Driver<Int>
        let conclusionTime: Driver<Int>
        let date: Driver<Date>
        let submitTrigger: Driver<Void>
    }

    struct Output {
        let submitEnabled: Driver<Bool>
        let intro: Driver<String>
        let main: Driver<String>
        let conclusion: Driver<String>
        let dismiss: Driver<Void>
    }

    func transform(input: Input) -> Output {

        let times = Driver.combineLatest(input.introTime,
                                         input.mainTime,
                                         input.conclusionTime)

        let discussion = Driver.combineLatest(input.title, times, input.date)

        let canSubmit = discussion.map { title, _, _ in
            return !title.isEmpty
        }

        let submit = input.submitTrigger
            .withLatestFrom(discussion)
            .map { return Discussion(
                date: $2, durations: [$1.0, $1.1, $1.2], topic: $0
            ) }
            .flatMapLatest { [unowned self] discussion in
                self.usecase.add(room: 1, discussion: discussion)
                    .asDriverOnErrorJustComplete()
            }

        let dismiss = Driver.of(submit, input.exitTrigger)
            .merge()
                .do(onNext: self.navigator.toChatRoom)

        return Output(
            submitEnabled: canSubmit,
            intro: input.introTime.map { String($0) }.asDriver(),
            main: input.mainTime.map { String($0) }.asDriver(),
            conclusion: input.conclusionTime.map {String($0)}.asDriver(),
            dismiss: dismiss
        )
    }

}
