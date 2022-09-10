//
//  MyPageViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation
import RxCocoa

final class ReadProfileViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String
    private let navigator: ReadProfileNavigator
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         navigator: ReadProfileNavigator,
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

        let profileURL = myInfo.map { $0?.profileURL }

        let score = myInfo.compactMap { myInfo -> (win: Int, draw: Int, lose: Int)? in
            guard let myInfo = myInfo
            else { return nil }
            return (myInfo.win, myInfo.draw, myInfo.lose)
        }

        let nickname = myInfo.compactMap { $0?.nickname }

        let settingEvent = input.settingTrigger
            .do(onNext: self.navigator.toSetting)

        let uidAndNicknameAndProfileURL: Driver<(String, String, URL?)> = myInfo.compactMap { userInfo in
            guard let userInfo = userInfo else { return nil }
            return (userInfo.uid, userInfo.nickname, userInfo.profileURL)
        }

        let editEvent = input.profileEditTrigger
            .withLatestFrom(uidAndNicknameAndProfileURL)
            .do(onNext: self.navigator.toProfileEdit)
            .mapToVoid()

        let events = Driver.of(settingEvent, editEvent).merge()

        return Output(
            profileURL: profileURL,
            score: score,
            nickname: nickname,
            events: events
        )
    }

}

extension ReadProfileViewModel {

    struct Input {
        let reportTrigger: Driver<Void>
        let settingTrigger: Driver<Void>
        let profileEditTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
    }

    struct Output {
        let profileURL: Driver<URL?>
        let score: Driver<(win: Int, draw: Int, lose: Int)>
        let nickname: Driver<String>
        let events: Driver<Void>
    }

}
