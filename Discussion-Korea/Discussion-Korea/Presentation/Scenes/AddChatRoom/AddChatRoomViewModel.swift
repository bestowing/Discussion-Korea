//
//  AddChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import RxCocoa

final class AddChatRoomViewModel: ViewModelType {

    // MARK: properties

    private let navigator: AddChatRoomNavigator
    private let userInfoUsecase: UserInfoUsecase
    private let chatRoomUsecase: ChatRoomsUsecase

    // MARK: - init/deinit

    init(navigator: AddChatRoomNavigator,
         userInfoUsecase: UserInfoUsecase,
         chatRoomUsecase: ChatRoomsUsecase) {
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
        self.chatRoomUsecase = chatRoomUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let userID = self.userInfoUsecase.uid()
            .asDriverOnErrorJustComplete()

        let chatRoom = Driver.combineLatest(input.title, userID)

        let canSubmit = chatRoom.map { (title, _) in
            return !title.isEmpty
        }

        let submit = input.submitTrigger
            .withLatestFrom(chatRoom)
            .flatMapLatest { [unowned self] (title, userID) in
                self.chatRoomUsecase.create(title: title, adminUID: userID)
                    .asDriverOnErrorJustComplete()
            }

        let dismiss = Driver.of(submit, input.exitTrigger)
            .merge()
            .do(onNext: self.navigator.toChatRoomList)

        let events = Driver.of(dismiss, submit.mapToVoid())
            .merge()

        return Output(
            submitEnabled: canSubmit,
            events: events
        )
    }

}

extension AddChatRoomViewModel {

    struct Input {
        let title: Driver<String>
        let exitTrigger: Driver<Void>
        let submitTrigger: Driver<Void>
    }

    struct Output {
        let submitEnabled: Driver<Bool>
        let events: Driver<Void>
    }

}
