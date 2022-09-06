//
//  EnterGuestViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String
    private let nickname: String?
    private let profileURL: URL?

    private let navigator: EditProfileNavigator
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         nickname: String?,
         profileURL: URL?,
         navigator: EditProfileNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.userID = userID
        self.nickname = nickname
        self.profileURL = profileURL
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

        // TODO: 이미지 관련 유즈케이스도 분리하기
        let permission = input.imageTrigger
            .flatMapLatest {
                return Observable<PHAuthorizationStatus>.create { subscribe in
                    if #available(iOS 14, *) {
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { subscribe.onNext($0) }
                    } else {
                        PHPhotoLibrary.requestAuthorization { subscribe.onNext($0) }
                    }
                    return Disposables.create()
                }.asDriverOnErrorJustComplete()
            }

        let albumAuthorized = permission
            .map { status -> Bool in
                var authorized: [PHAuthorizationStatus] = [.authorized]
                if #available(iOS 14, *) {
                    authorized.append(.limited)
                }
                return authorized.contains(status)
            }

        let settingAppEvent = albumAuthorized.filter { !$0 }
            .mapToVoid()
            .do(onNext: self.navigator.toSettingAppAlert)

        let oldNickname = Driver.of(self.nickname)
        let oldProfileURL = Driver.of(self.profileURL)

        let profileImage = albumAuthorized.filter { $0 }
            .flatMapLatest { [unowned self] _ -> Driver<URL?> in
                self.navigator.toImagePicker()
                    .asDriverOnErrorJustComplete()
            }

        let profileURL = Driver.concat([oldProfileURL, profileImage])

        let nicknameAndProfile = Driver.combineLatest(input.nickname, profileURL)

        let canSubmit = nicknameAndProfile.map { (title, _) in
            return !title.isEmpty
        }

        let submitEvent = input.submitTrigger
            .withLatestFrom(nicknameAndProfile)
            .flatMapLatest { [unowned self] (nickname, profileURL) in
                self.userInfoUsecase.add(userInfo: (self.userID, nickname, profileURL))
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let dismissEvent = Driver.of(submitEvent, input.exitTrigger)
            .merge()
            .do(onNext: self.navigator.toMyPage)

        let loading = activityTracker.asDriver()
        let errorEvent = errorTracker.asDriver()
            .do(onNext: self.navigator.toErrorAlert)
            .mapToVoid()

        let events = Driver.of(submitEvent, dismissEvent, settingAppEvent, errorEvent)
            .merge()

        return Output(
            loading: loading,
            oldNickname: oldNickname,
            profileURL: profileURL.compactMap { $0 },
            submitEnable: canSubmit,
            events: events
        )
    }

}

extension EditProfileViewModel {

    struct Input {
        let nickname: Driver<String>
        let exitTrigger: Driver<Void>
        let imageTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let oldNickname: Driver<String?>
        let profileURL: Driver<URL>
        let submitEnable: Driver<Bool>
        let events: Driver<Void>
    }

}
