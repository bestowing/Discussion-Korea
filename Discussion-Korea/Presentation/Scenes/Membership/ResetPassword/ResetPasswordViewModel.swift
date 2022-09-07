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
        let activityTracker = ActivityTracker()
        let errorTracker = ErrorTracker()

        let emailResult = input.email
            .flatMapLatest { [unowned self] email in
                self.userInfoUsecase.isValid(email: email)
                    .asDriverOnErrorJustComplete()
            }

        let canSend = emailResult.map { $0 == .success }

        let sendEvent = input.sendTrigger
            .withLatestFrom(input.email)
            .flatMapLatest { [unowned self] email in
                self.userInfoUsecase.resetPassword(email)
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: self.navigator.toSuccessAlert)

        let exitEvent = input.exitTrigger
            .do(onNext: self.navigator.toSignIn)

        let errorEvent = errorTracker.asDriver()
            .do(onNext: self.navigator.toErrorAlert)
            .mapToVoid()

        let events = Driver.of(sendEvent, exitEvent, errorEvent)
            .merge()

        return Output(
            loading: activityTracker.asDriver(),
            emailResult: emailResult,
            sendEnabled: canSend.startWith(false),
            sendEvent: sendEvent,
            events: events
        )
    }

}

extension ResetPasswordViewModel {

    struct Input {
        let email: Driver<String>
        let sendTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let loading: Driver<Bool>
        let emailResult: Driver<FormResult>
        let sendEnabled: Driver<Bool>
        let sendEvent: Driver<Void>
        let events: Driver<Void>
    }

}
