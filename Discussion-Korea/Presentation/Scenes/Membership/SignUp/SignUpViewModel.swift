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
        let activityTracker = ActivityTracker()
        let errorTracker = ErrorTracker()

        let userInfo = Driver.combineLatest(input.email, input.password)

        let emailResult = input.email
            .flatMapLatest { [unowned self] email in
                self.userInfoUsecase.isValid(email: email)
                    .asDriverOnErrorJustComplete()
            }

        let passwordResult = input.password
            .flatMapLatest { [unowned self] password in
                self.userInfoUsecase.isValid(password: password)
                    .asDriverOnErrorJustComplete()
            }

        let passwordCheckResult = input.passwordCheck
            .withLatestFrom(input.password) { ($0, $1) }
            .map {
                $0 == $1 ? FormResult.success : FormResult.failure("비밀번호가 일치하지 않습니다")
            }

        let nicknameResult = input.nickname
            .flatMapLatest { [unowned self] nickname in
                self.userInfoUsecase.isValid(nickname: nickname)
                    .asDriverOnErrorJustComplete()
            }

        let canRegister = Driver.combineLatest(
            emailResult, passwordResult, passwordCheckResult, nicknameResult
        ) {
            return $0 == FormResult.success && $1 == FormResult.success && $2 == FormResult.success && $3 == FormResult.success
        }

        let loading = activityTracker.asDriver()
        let errorEvent = errorTracker.asDriver()
            .do(onNext: self.navigator.toErrorAlert)
            .mapToVoid()

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toSignIn)

        let registerEvent = input.register
            .withLatestFrom(userInfo) { $1 }
            .flatMapLatest { [unowned self] userInfo in
                self.userInfoUsecase.register(userInfo: userInfo)
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let events = Driver.of(exitEvent, registerEvent, errorEvent).merge()

        return Output(
            loading: loading,
            emailResult: emailResult,
            passwordResult: passwordResult,
            passwordCheckResult: passwordCheckResult,
            nicknameResult: nicknameResult,
            registerEnabled: canRegister.startWith(false),
            events: events
        )
    }

}

extension SignUpViewModel {

    struct Input {
        let exitTrigger: Driver<Void>
        let email: Driver<String>
        let password: Driver<String>
        let passwordCheck: Driver<String>
        let nickname: Driver<String>
        let register: Driver<Void>
    }

    struct Output {
        let loading: Driver<Bool>
        let emailResult: Driver<FormResult>
        let passwordResult: Driver<FormResult>
        let passwordCheckResult: Driver<FormResult>
        let nicknameResult: Driver<FormResult>
        let registerEnabled: Driver<Bool>
        let events: Driver<Void>
    }

}
