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
        let activityTracker = ActivityTracker()
        let errorTracker = ErrorTracker()

        let userInfo = Driver.combineLatest(input.email, input.password)

        let registerEvent = input.signInTrigger
            .withLatestFrom(userInfo) { $1 }
            .flatMapLatest { [unowned self] userInfo in
                self.userInfoUsecase.signIn(userInfo: userInfo)
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let canSignIn = userInfo.map { email, password in
            return !email.isEmpty && !password.isEmpty
        }

        let signUpEvent = input.signUpTrigger
            .do(onNext: self.navigator.toSignUp)

        let resetPasswordEvent = input.resetPasswordTrigger
            .do(onNext: self.navigator.toResetPassword)

        let errorEvent = errorTracker.asDriver()
            .do(onNext: self.navigator.toErrorAlert)
            .mapToVoid()

        let events = Driver.of(signUpEvent, resetPasswordEvent, registerEvent, errorEvent).merge()

        return Output(
            loading: activityTracker.asDriver(),
            signInEnabled: canSignIn,
            events: events
        )
    }

}

extension SignInViewModel {

    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let signInTrigger: Driver<Void>
        let signUpTrigger: Driver<Void>
        let resetPasswordTrigger: Driver<Void>
    }

    struct Output {
        let loading: Driver<Bool>
        let signInEnabled: Driver<Bool>
        let events: Driver<Void>
    }

}
