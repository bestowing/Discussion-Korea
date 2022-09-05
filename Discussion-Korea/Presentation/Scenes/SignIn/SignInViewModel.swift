//
//  SignInViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import RxCocoa

final class SignInViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: SignInNavigator

    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: SignInNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let signUpEvent = input.signUpTrigger
            .do(onNext: self.navigator.toSignUp)

        return Output(events: signUpEvent)
    }

}

extension SignInViewModel {

    struct Input {
        let signUpTrigger: Driver<Void>
    }

    struct Output {
        let events: Driver<Void>
    }

}
