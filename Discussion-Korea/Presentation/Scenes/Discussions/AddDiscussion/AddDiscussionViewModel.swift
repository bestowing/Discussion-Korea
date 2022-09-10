//
//  AddDiscussionViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation
import RxCocoa

final class AddDiscussionViewModel: ViewModelType {

    // MARK: - properties

    private let chatRoom: ChatRoom

    private let navigator: AddDiscussionNavigator
    private let builderUsecase: BuilderUsecase
    private let discussionUsecase: DiscussionUsecase

    // MARK: - init/deinit

    init(chatRoom: ChatRoom,
         navigator: AddDiscussionNavigator,
         builderUsecase: BuilderUsecase,
         discussionUsecase: DiscussionUsecase) {
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.builderUsecase = builderUsecase
        self.discussionUsecase = discussionUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        let discussionBasic = Driver.combineLatest(input.topic, input.date)

        let topicResult = input.topic
            .flatMapLatest { [unowned self] topic in
                self.discussionUsecase.isValid(topic: topic)
                    .asDriverOnErrorJustComplete()
            }

        let updateBuilderEvent = discussionBasic
            .debounce(.milliseconds(500))
            .flatMapLatest { [unowned self] basic in
                self.builderUsecase.setBasic(basic)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let canNext = discussionBasic
            .map { title, date -> Bool in
                return !title.isEmpty && date.timeIntervalSinceNow >= 300
            }

        let dismissEvent = input.exitTrigger
            .do(onNext: self.builderUsecase.clear)
            .do(onNext: self.navigator.toChatRoom)

        let nextEvent = input.nextTrigger
            .map { [unowned self] _ in self.chatRoom }
            .do(onNext: self.navigator.toSetDiscussionTime)
            .mapToVoid()

        let events = Driver.of(updateBuilderEvent, dismissEvent, nextEvent).merge()

        return Output(
            topicResult: topicResult,
            nextEnabled: canNext,
            events: events
        )
    }

}

extension AddDiscussionViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
        let topic: Driver<String>
        let date: Driver<Date>
        let nextTrigger: Driver<Void>
    }

    struct Output {
        let topicResult: Driver<FormResult>
        let nextEnabled: Driver<Bool>
        let events: Driver<Void>
    }

}
