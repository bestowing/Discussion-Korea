//
//  LawViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import RxCocoa

final class LawViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: LawNavigator

    private let lawUsecase: LawUsecase

    // MARK: - init/deinit

    init(navigator: LawNavigator,
         lawUsecase: LawUsecase) {
        self.navigator = navigator
        self.lawUsecase = lawUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let laws = self.lawUsecase.laws().asDriverOnErrorJustComplete()
            .map { $0.map { LawItemViewModel(content: $0) } }

        let events = input.exitTrigger
            .do(onNext: self.navigator.toHome)

        return Output(laws: laws, events: events)
    }

}

extension LawViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let laws: Driver<[LawItemViewModel]>
        let events: Driver<Void>
    }

}
