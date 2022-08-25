//
//  ChartViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import RxCocoa

final class ChartViewModel: ViewModelType {

    // MARK: properties

    private let navigator: ChartNavigator

    // MARK: - init/deinit

    init(navigator: ChartNavigator) {
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let events = input.exitTrigger
            .do(onNext: self.navigator.toHome)

        return Output(events: events)
    }

}

extension ChartViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let events: Driver<Void>
    }

}
