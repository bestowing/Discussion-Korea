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

    private let navigator: HomeNavigator
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: HomeNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let userID = self.userInfoUsecase.uid()
            .asDriverOnErrorJustComplete()

        let myInfo = userID
            .flatMap { [unowned self] userID in
                self.userInfoUsecase
                    .userInfo(userID: userID)
                    .asDriverOnErrorJustComplete()
            }

        let nickname = myInfo.compactMap { $0?.nickname }
            .map { $0 + "님, 안녕하세요 🇰🇷" }

        let day = myInfo.compactMap { $0?.registerAt }

        let chartEvent = input.chartTrigger
            .do(onNext: self.navigator.toChart)

        let lawEvent = input.lawTrigger
            .do(onNext: self.navigator.toLaw)

        let guideEvent = input.guideTrigger
            .do(onNext: self.navigator.toGuide)

        let events = Driver.of(chartEvent, lawEvent, guideEvent).merge()

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
