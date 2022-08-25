//
//  HomeViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class HomeViewModel: ViewModelType {

    // MARK: properties

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

        //        let profileURL = myInfo.compactMap { $0?.profileURL }

        //        let score = myInfo.compactMap { myInfo -> String? in
        //            guard let myInfo = myInfo
        //            else { return nil }
        //            return "\(myInfo.win)승 \(myInfo.draw)무 \(myInfo.lose)패"
        //        }

        let myInfo = userID
            .flatMap { [unowned self] userID in
                self.userInfoUsecase
                    .userInfo(userID: userID)
                    .asDriverOnErrorJustComplete()
            }

        let nickname = myInfo.compactMap { $0?.nickname }
            .map { $0 + "님, 안녕하세요 🇰🇷" }

        let chartEvent = input.chartTrigger
            .do(onNext: self.navigator.toChart)

        let enterEvent = myInfo
            .filter { return $0 == nil }
            .withLatestFrom(userID)
            .do(onNext: self.navigator.toEnterGame)
            .mapToVoid()

        let events = Driver.of(enterEvent, chartEvent).merge()

        return Output(
            nickname: nickname,
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
        let events: Driver<Void>
    }

}
