//
//  LawViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import Foundation
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

        let laws = self.lawUsecase.laws()
            .asDriverOnErrorJustComplete()

        let selectionEvent = input.selection
            .withLatestFrom(laws) { (indexPath, laws) -> Law in
                return laws.laws[indexPath.item]
            }
            .do(onNext: self.navigator.toLawDetail)
            .mapToVoid()

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toHome)

        let events = Driver.of(selectionEvent, exitEvent)
            .merge()

        return Output(
            lastUpdated: laws.map { $0.lastUpdated },
            laws: laws.map { $0.laws },
            events: events
        )
    }

}

extension LawViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }

    struct Output {
        let lastUpdated: Driver<Date>
        let laws: Driver<[Law]>
        let events: Driver<Void>
    }

}
