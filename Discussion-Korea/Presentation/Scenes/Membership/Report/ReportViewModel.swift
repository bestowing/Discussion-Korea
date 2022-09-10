//
//  ReportViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

import RxCocoa

final class ReportViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String
    private let reportedUserInfo: UserInfo

    private let navigator: ReportNavigator

    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         reportedUserInfo: UserInfo,
         navigator: ReportNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.userID = userID
        self.reportedUserInfo = reportedUserInfo
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        let sendEvent = input.sendEvent
            .withLatestFrom(input.reportReason)
            .flatMapLatest { [unowned self] reason in
                self.userInfoUsecase.report(
                    from: self.userID, to: self.reportedUserInfo.uid, reason: reason
                )
                .asDriverOnErrorJustComplete()
            }
            .do(onNext: self.navigator.toChatRoomSideMenu)

        return Output(events: sendEvent)
    }

}

extension ReportViewModel {

    struct Input {
        let reportReason: Driver<String>
        let sendEvent: Driver<Void>
    }

    struct Output {
        let events: Driver<Void>
    }

}
