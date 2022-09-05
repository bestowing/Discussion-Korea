//
//  LawDetailViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/02.
//

import RxCocoa

final class LawDetailViewModel: ViewModelType {

    // MARK: - properties

    private let law: Law
    private let navigator: LawDetailNavigator

    // MARK: - init/deinit

    init(law: Law,
         navigator: LawDetailNavigator) {
        self.law = law
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        return Output(
            law: Driver.of(self.law)
        )
    }

}

extension LawDetailViewModel {

    struct Input {}

    struct Output {
        let law: Driver<Law>
    }

}
