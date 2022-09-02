//
//  ChatRoomSideMenuViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomSideMenuViewModel: ViewModelType {

    // MARK: properties

    private let uid: String
    private let chatRoom: ChatRoom
    private let navigator: ChatRoomSideMenuNavigator

    private let userInfoUsecase: UserInfoUsecase
    private let discussionUsecase: DiscussionUsecase

    // MARK: - init/deinit

    init(uid: String,
         chatRoom: ChatRoom,
         navigator: ChatRoomSideMenuNavigator,
         userInfoUsecase: UserInfoUsecase,
         discussionUsecase: DiscussionUsecase) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
        self.discussionUsecase = discussionUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let participants = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.userInfos(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .map {
                        $0.map { (_, value) in
                            ParticipantItemViewModel(with: value, isSelf: self.uid == value.uid )
                        }
                    }
            }

        let calendarEvent = input.calendar
            .do(onNext: { [unowned self] in
                self.navigator.toChatRoomSchedule(self.chatRoom)
            })

        let chatRoomTitle = Driver.from([self.chatRoom.title])

        let side = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.userInfo(roomID: self.chatRoom.uid, with: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let canParticipate: Driver<Bool> = side
            .map { side in
                guard let side = side
                else { return true }
                return ![Side.agree, Side.disagree].contains(side)
            }

        let status = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.status(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let opinions = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.opinions(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let discussionOngoing: Driver<Bool> = status.map { $0 > 1 }

        let sideEvent = input.side
            .flatMap { [unowned self] side in
                self.userInfoUsecase.support(side: side, roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let supportSide = input.viewWillAppear
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.supporter(roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let selectedSide: Driver<Side?> = Driver.combineLatest(discussionOngoing, supportSide) {
            guard $0 else { return nil }
            return $1
        }

        let events = Driver.of(
            calendarEvent,
            sideEvent
        )
            .merge()

        return Output(
            chatRoomTitle: chatRoomTitle,
            canParticipate: canParticipate,
            selectedSide: selectedSide,
            opinions: opinions,
            participants: participants,
            discussionOngoing: discussionOngoing,
            events: events
        )
    }

}

extension ChatRoomSideMenuViewModel {

    struct Input {
        let viewWillAppear: Driver<Void>
        let calendar: Driver<Void>
        let side: Driver<Side>
    }
    
    struct Output {
        let chatRoomTitle: Driver<String>
        let canParticipate: Driver<Bool>
        let selectedSide: Driver<Side?>
        let opinions: Driver<(UInt, UInt)>
        let participants: Driver<[ParticipantItemViewModel]>
        let discussionOngoing: Driver<Bool>
        let events: Driver<Void>
    }

}
