//
//  SignUpViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import RxCocoa

final class SignUpViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: SignUpNavigator

    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: SignUpNavigator,
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

extension SignUpViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
        let email: Driver<String>
        let password: Driver<String>
        let passwordCheck: Driver<String>
        let nickname: Driver<String>
    }

    struct Output {
        let events: Driver<Void>
    }

}
