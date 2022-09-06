//
//  AddChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

final class AddChatRoomViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String

    private let navigator: AddChatRoomNavigator
    private let userInfoUsecase: UserInfoUsecase
    private let chatRoomUsecase: ChatRoomsUsecase

    // MARK: - init/deinit

    init(userID: String,
         navigator: AddChatRoomNavigator,
         userInfoUsecase: UserInfoUsecase,
         chatRoomUsecase: ChatRoomsUsecase) {
        self.userID = userID
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
        self.chatRoomUsecase = chatRoomUsecase
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

        let profileImage = albumAuthorized.filter { $0 }
                .flatMapLatest { [unowned self] _ -> Driver<URL?> in
                    self.navigator.toImagePicker()
                        .asDriverOnErrorJustComplete()
                }

        let titleAndProfile = Driver.combineLatest(input.title, profileImage.startWith(nil))

        let canSubmit = titleAndProfile.map { (title, _) in
            return !title.isEmpty
        }

        let submitEvent = input.submitTrigger
            .withLatestFrom(titleAndProfile) {
                ChatRoom(uid: "", title: $1.0, adminUID: self.userID, profileURL: $1.1)
            }
            .flatMapLatest { [unowned self] chatRoom in
                self.chatRoomUsecase.create(chatRoom: chatRoom)
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let dismissEvent = Driver.of(submitEvent, input.exitTrigger)
            .merge()
            .do(onNext: self.navigator.toChatRoomList)

        let loading = activityTracker.asDriver()
        let errorEvent = errorTracker.asDriver()
            .do(onNext: self.navigator.toErrorAlert)
            .mapToVoid()

        let events = Driver.of(submitEvent.mapToVoid(), dismissEvent, settingAppEvent, errorEvent)
            .merge()

        return Output(
            loading: loading,
            submitEnabled: canSubmit,
            profileImage: profileImage,
            events: events
        )
    }

}

extension AddChatRoomViewModel {

    struct Input {
        let title: Driver<String>
        let imageTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
    }

    struct Output {
        let loading: Driver<Bool>
        let submitEnabled: Driver<Bool>
        let profileImage: Driver<URL?>
        let events: Driver<Void>
    }

}
