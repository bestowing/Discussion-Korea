//
//  ResetPasswordViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import RxCocoa

final class ResetPasswordViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: ResetPasswordNavigator

    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: ResetPasswordNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toSignIn)

        return Output(events: exitEvent)
    }

}

extension ResetPasswordViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let events: Driver<Void>
    }

}
