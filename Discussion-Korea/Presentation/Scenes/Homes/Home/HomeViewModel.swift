//
//  HomeViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class HomeViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String

    private let navigator: HomeNavigator
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         navigator: HomeNavigator,
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

        let myInfo = self.userInfoUsecase
            .userInfo(userID: self.userID)
            .asDriverOnErrorJustComplete()

        let nickname = myInfo.compactMap { $0?.nickname }
            .map { $0 + "님, 안녕하세요 🇰🇷" }

        let day = myInfo.compactMap { $0?.registerAt }

        let onboardingEvent = myInfo
            .filter { $0 == nil }
            .map { [unowned self] _ in self.userID }
            .do(onNext: self.navigator.toOnboarding)
            .mapToVoid()

        let chartEvent = input.chartTrigger
            .do(onNext: self.navigator.toChart)

        let lawEvent = input.lawTrigger
            .do(onNext: self.navigator.toLaw)

        let guideEvent = input.guideTrigger
            .do(onNext: self.navigator.toGuide)

        let events = Driver.of(chartEvent, lawEvent, guideEvent, onboardingEvent).merge()

        return Output(
            nickname: nickname,
            day: day,
            events: events
        )
    }

}

extension HomeViewModel {

    struct Input {
        let chartTrigger: Driver<Void>
        let lawTrigger: Driver<Void>
        let guideTrigger: Driver<Void>
    }
    
    struct Output {
        let nickname: Driver<String>
        let day: Driver<Date>
        let events: Driver<Void>
    }

}
