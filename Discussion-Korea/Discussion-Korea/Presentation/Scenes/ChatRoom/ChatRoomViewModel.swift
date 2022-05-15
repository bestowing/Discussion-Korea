//
//  ChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa
import RxSwift

final class ChatRoomViewModel: ViewModelType {

    private let chatsUsecase: ChatsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let discussionUsecase: DiscussionUsecase
    private let navigator: ChatRoomNavigator

    init(chatsUsecase: ChatsUsecase,
         userInfoUsecase: UserInfoUsecase,
         discussionUsecase: DiscussionUsecase,
         navigator: ChatRoomNavigator) {
        self.chatsUsecase = chatsUsecase
        self.userInfoUsecase = userInfoUsecase
        self.discussionUsecase = discussionUsecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {

        let uid = self.userInfoUsecase
            .uid()
            .asDriverOnErrorJustComplete()

        let myInfo = uid
            .flatMap { [unowned self] uid in
                self.userInfoUsecase
                    .userInfo(room: 1, with: uid)
                    .asDriverOnErrorJustComplete()
            }

        let remainTime = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.remainTime(room: 1)
                    .asDriverOnErrorJustComplete()
            }
            .map { date -> Int in
                let timeInterval = Date().timeIntervalSince(date)
                print(Int(timeInterval))
                return abs(Int(timeInterval))
            }
            .flatMapLatest { remainSeconds in
                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { remainSeconds - $0 }
                    .take(until: { $0 == 0 })
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let enterEvent = myInfo
            .filter { return $0 == nil }
            .flatMap { [unowned self] _ in
                self.navigator.toNicknameAlert()
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (nickname, uid) in
                self.userInfoUsecase.add(room: 1, userInfo: UserInfo(uid: uid, nickname: nickname))
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        // 한번 딱 가져오고 그다음부터 추가되는거 감지하는걸로 바꾸기
        let userInfos = input.trigger
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.connect(room: 1)
                    .asDriverOnErrorJustComplete()
                    .scan([String: UserInfo]()) { userInfos, userInfo in
                        var userInfos = userInfos
                        userInfos[userInfo.uid] = userInfo
                        return userInfos
                    }
            }

        let uidAndUserInfos = Driver.combineLatest(uid, userInfos)

        let chats = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatsUsecase.connect(room: 1)
                    .asDriverOnErrorJustComplete()
            }

        let chatItems = chats
            .withLatestFrom(uidAndUserInfos) { ($0, $1) }
            .scan([ChatItemViewModel]()) { (viewModels, args) in
                var chat = args.0
                let uid = args.1.0
                let userInfos = args.1.1
                chat.nickName = userInfos[chat.userID]?.nickname
                let newItemViewModel: ChatItemViewModel
                if let last = viewModels.last,
                   last.chat.userID == chat.userID,
                   let lastDate = last.chat.date,
                   let currentDate = chat.date,
                   Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                    viewModels.last?.chat.date = nil
                }
                if chat.userID == uid {
                    newItemViewModel = SelfChatItemViewModel(with: chat)
                } else {
                    if let last = viewModels.last,
                       last.chat.userID == chat.userID {
                        newItemViewModel = SerialOtherChatItemViewModel(with: chat)
                    } else {
                        newItemViewModel = OtherChatItemViewModel(with: chat)
                    }
                }
                return viewModels + [newItemViewModel]
            }

        let status = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.status(room: 1)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: { print($0) })

        let selectedSide = status
            .filter { return $0 == 1 }
            .flatMap { [unowned self] status in
                self.navigator.toSideAlert()
                    .asDriverOnErrorJustComplete()
            }

        let side = Driver.of(selectedSide, myInfo.compactMap { $0?.side }).merge()

        let sideEvent = selectedSide
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (side, uid) in
                self.userInfoUsecase.add(room: 1, uid: uid, side: side)
                    .asDriverOnErrorJustComplete()
            }

        let voteEvent = status
            .withLatestFrom(side) { ($0, $1) }
            .filter { return $0.0 == 7 && $0.1 == Side.judge }
            .flatMap { [unowned self] status in
                self.navigator.toVoteAlert()
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (vote, uid) in
                self.userInfoUsecase.vote(room: 1, uid: uid, side: vote)
                    .asDriverOnErrorJustComplete()
            }

        let contentEmpty = input.content.map { !$0.isEmpty }

        let canEditable = Driver.combineLatest(status, side) { (status, side) -> Bool in
            guard [2, 3, 4, 5, 6, 7].contains(status)
            else { return true }
            switch side {
            case .agree:
                return [2, 4, 5].contains(status)
            case .disagree:
                return [3, 4, 6].contains(status)
            default:
                return false
            }
        }

        let canSend = Driver.of(
            contentEmpty,
            canEditable
                .withLatestFrom(contentEmpty) { return $0 && $1 }
        )
            .merge()

        let contentAndUID = Driver.combineLatest(input.content, uid)

        let sideMenuEvent = input.menu
            .do(onNext: self.navigator.toSideMenu)

        let sendEvent = input.send
            .withLatestFrom(contentAndUID)
            .map { (content, uid) -> Chat in
                Chat(userID: uid, content: content, date: Date())
            }
            .flatMap { [unowned self] in
                self.chatsUsecase.send(room: 1, chat: $0)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let events = Driver.of(voteEvent, sideEvent, sideMenuEvent, sendEvent, enterEvent, remainTime)
            .merge()

        return Output(
            chatItems: chatItems,
            userInfos: userInfos,
            sendEnable: canSend,
            editableEnable: canEditable,
            sendEvent: sendEvent,
            events: events
        )
    }

}

extension ChatRoomViewModel {

    struct Input {
        let trigger: Driver<Void>
        let send: Driver<Void>
        let menu: Driver<Void>
        let content: Driver<String>
    }
    
    struct Output {
        let chatItems: Driver<[ChatItemViewModel]>
        let userInfos: Driver<[String: UserInfo]>
        let sendEnable: Driver<Bool>
        let editableEnable: Driver<Bool>
        let sendEvent: Driver<Void>
        let events: Driver<Void>
    }

}
