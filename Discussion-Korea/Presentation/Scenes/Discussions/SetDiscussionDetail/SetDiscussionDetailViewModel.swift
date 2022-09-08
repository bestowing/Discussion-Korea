//
//  SetDiscussionDetail.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import RxCocoa

final class SetDiscussionDetailViewModel: ViewModelType {

    // MARK: - properties
    
    private let chatRoom: ChatRoom

    private let navigator: SetDiscussionDetailNavigator
    private let builderUsecase: BuilderUsecase
    private let discussionUsecase: DiscussionUsecase

    // MARK: - init/deinit

    init(chatRoom: ChatRoom,
         navigator: SetDiscussionDetailNavigator,
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

    func transform(input: Input) -> Output {
        let times = Driver.combineLatest(
            input.introTime,
            input.mainTime,
            input.conclusionTime
        )

        let discussionDetail = Driver.combineLatest(times, input.isFullTime) { ($0.0, $0.1, $0.2, $1) }

        let updateBuilderEvent = discussionDetail
            .flatMapLatest { [unowned self] detail in
                self.builderUsecase.setDetail(detail)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let canSubmit = discussionDetail
            .map { _ in true }

        let submitEvent = input.submitTrigger
            .flatMapLatest { [unowned self] _ in
                self.builderUsecase.getResult()
                    .compactMap { $0 }
                    .asDriverOnErrorJustComplete()
            }
            .flatMapLatest { [unowned self] discussion in
                self.discussionUsecase.add(
                    roomUID: self.chatRoom.uid, discussion: discussion
                )
                .asDriverOnErrorJustComplete()
            }
            .mapToVoid()
            .do(onNext: self.navigator.toChatRoom)

        let events = Driver.of(submitEvent, updateBuilderEvent).merge()

        return Output(
            submitEnabled: canSubmit,
            intro: input.introTime.map { String($0) }.asDriver(),
            main: input.mainTime.map { String($0) }.asDriver(),
            conclusion: input.conclusionTime.map {String($0)}.asDriver(),
            events: events
        )
    }

}

extension SetDiscussionDetailViewModel {

    struct Input {
        let introTime: Driver<Int>
        let mainTime: Driver<Int>
        let conclusionTime: Driver<Int>
        let isFullTime: Driver<Bool>
        let submitTrigger: Driver<Void>
    }

    struct Output {
        let submitEnabled: Driver<Bool>
        let intro: Driver<String>
        let main: Driver<String>
        let conclusion: Driver<String>
        let events: Driver<Void>
    }

}
