//
//  EnterGuestViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import RxCocoa

final class EnterGuestViewModel: ViewModelType {

    // MARK: properties

    private let userID: String

    private let navigator: EnterGuestNavigator
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         navigator: EnterGuestNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.userID = userID
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods
    func transform(input: Input) -> Output {

        let nickname = input.nickname

        let canSubmit = nickname.map { title in
            return !title.isEmpty
        }

        let submitEvent = input.submitTrigger
            .withLatestFrom(nickname)
            .map { [unowned self] nickname in
                return UserInfo(uid: self.userID, nickname: nickname)
            }
            .flatMapLatest { [unowned self] userInfo in
                self.userInfoUsecase.add(userInfo: userInfo)
                    .asDriverOnErrorJustComplete()
            }

        let dismissEvent = Driver.of(submitEvent, input.guestTrigger)
            .merge()
            .do(onNext: self.navigator.toHome)

        let events = Driver.of(submitEvent, dismissEvent)
            .merge()

        return Output(submitEnable: canSubmit, events: events)
    }

}

extension EnterGuestViewModel {

    struct Input {
        let nickname: Driver<String>
        let guestTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
    }
    
    struct Output {
        let submitEnable: Driver<Bool>
        let events: Driver<Void>
    }

}
