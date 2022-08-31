//
//  GuideViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import RxCocoa

final class GuideViewModel: ViewModelType {

    // MARK: properties

    private let navigator: GuideNavigator

    private let guideUsecase: GuideUsecase

    // MARK: - init/deinit

    init(navigator: GuideNavigator,
         guideUsecase: GuideUsecase) {
        self.navigator = navigator
        self.guideUsecase = guideUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let guides = self.guideUsecase.guides().asDriverOnErrorJustComplete()

        let events = input.exitTrigger
            .do(onNext: self.navigator.toHome)

        return Output(guides: guides, events: events)
    }

}

extension GuideViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let guides: Driver<[Guide]>
        let events: Driver<Void>
    }

}
