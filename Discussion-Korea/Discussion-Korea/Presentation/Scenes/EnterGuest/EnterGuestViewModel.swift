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

        let profileImage = albumAuthorized.filter { $0 }
            .flatMapLatest { [unowned self] _ in
                self.navigator.toImagePicker()
                    .asDriverOnErrorJustComplete()
            }

        let dismissEvent = Driver.of(submitEvent, input.guestTrigger)
            .merge()
            .do(onNext: self.navigator.toHome)

        let events = Driver.of(submitEvent, dismissEvent, settingAppEvent)
            .merge()

        return Output(
            profileImage: profileImage,
            submitEnable: canSubmit,
            events: events
        )
    }

}

extension EnterGuestViewModel {

    struct Input {
        let nickname: Driver<String>
        let imageTrigger: Driver<Void>
        let guestTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
    }
    
    struct Output {
        let profileImage: Driver<URL>
        let submitEnable: Driver<Bool>
        let events: Driver<Void>
    }

}
