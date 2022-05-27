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

    // MARK: properties

    private let chatRoom: ChatRoom

    private let chatsUsecase: ChatsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let discussionUsecase: DiscussionUsecase

    private let navigator: ChatRoomNavigator

    // MARK: - init/deinit

    init(chatRoom: ChatRoom,
         chatsUsecase: ChatsUsecase,
         userInfoUsecase: UserInfoUsecase,
         discussionUsecase: DiscussionUsecase,
         navigator: ChatRoomNavigator) {
        self.chatRoom = chatRoom
        self.chatsUsecase = chatsUsecase
        self.userInfoUsecase = userInfoUsecase
        self.discussionUsecase = discussionUsecase
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let uid = self.userInfoUsecase
            .uid()
            .asDriverOnErrorJustComplete()

        let myInfo = uid
            .flatMap { [unowned self] userID in
                self.userInfoUsecase
                    .userInfo(roomID: self.chatRoom.uid, with: userID)
                    .asDriverOnErrorJustComplete()
            }

        let noticeHidden = PublishSubject<Bool>()

        let remainTime = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.remainTime(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }
            .map { date -> Int in
                let timeInterval = Date().timeIntervalSince(date)
                return abs(Int(timeInterval))
            }
            .flatMapLatest { remainSeconds in
                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { remainSeconds - $0 }
                    .take(until: { $0 == -1 })
                    .do(onNext: { _ in noticeHidden.on(.next(false)) },
                        onCompleted: { noticeHidden.on(.next(true)) })
                    .asDriverOnErrorJustComplete()
            }
            .map { "남은 시간: \(String(format: "%02d", $0 / 60)):\(String(format: "%02d", $0 % 60))" }

        let enterEvent = myInfo
            .filter { return $0 == nil }
            .flatMap { [unowned self] _ in
                self.navigator.toEnterAlert()
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(uid)
            .flatMap { [unowned self] (uid) in
                self.userInfoUsecase.add(roomID: self.chatRoom.uid, userID: uid)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        // TODO: 한번 딱 가져오고 그다음부터 추가되는거 감지하는걸로 바꾸기
        let userInfos = input.trigger
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.connect(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .scan([String: UserInfo]()) { userInfos, userInfo in
                        var userInfos = userInfos
                        userInfos[userInfo.uid] = userInfo
                        return userInfos
                    }
            }

        let uidAndUserInfos = Driver.combineLatest(uid, userInfos)

        // 배열을 방출한다
        // 여기서 오는건
        let remainChats = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatsUsecase.chats(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let remainChatItems = remainChats
            .withLatestFrom(uidAndUserInfos) { ($0, $1) }
            .map { (chats, args) -> [ChatItemViewModel] in
                let uid = args.0
                let userInfos = args.1
                var viewModels = [ChatItemViewModel]()
                for chat in chats {
                    var chat = chat
                    chat.nickName = userInfos[chat.userID]?.nickname
                    chat.profileURL = userInfos[chat.userID]?.profileURL
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
                    viewModels.append(newItemViewModel)
                }
                return viewModels
            }

        let chats = remainChats
            .flatMapFirst { [unowned self] remains in
                self.chatsUsecase.connect(roomUID: self.chatRoom.uid, after: remains.last!.uid!)
                    .asDriverOnErrorJustComplete()
            }

        let chatItems = chats
            .withLatestFrom(uidAndUserInfos) { ($0, $1) }
            .scan([ChatItemViewModel]()) { (viewModels, args) in
                var chat = args.0
                let uid = args.1.0
                let userInfos = args.1.1
                chat.nickName = userInfos[chat.userID]?.nickname
                chat.profileURL = userInfos[chat.userID]?.profileURL
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

        let masking = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatsUsecase.masking(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let maskingChatItems = Driver.combineLatest(masking.startWith(""), chatItems)
            .map { (uid: String, models) -> [ChatItemViewModel] in
                let model = models.first { $0.chat.uid == uid }
                model?.chat.toxic = true
                return models
            }

        let status = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.status(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let selectedSide = status
            .filter { return $0 == 1 }
            .flatMap { [unowned self] _ in
                self.navigator.toSideAlert()
                    .asDriverOnErrorJustComplete()
            }

        let clearSideEvent = status
            .filter { return $0 == 0 }
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (_, uid) in
                self.userInfoUsecase.clearSide(roomID: self.chatRoom.uid, userID: uid)
                    .asDriverOnErrorJustComplete()
            }

        let side = Driver.of(
            selectedSide.map { (side) -> Side? in return side }, myInfo.map { $0?.side }
        ).merge()

        let sideEvent = selectedSide
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (side, uid) in
                self.userInfoUsecase.add(roomID: self.chatRoom.uid, userID: uid, side: side)
                    .asDriverOnErrorJustComplete()
            }

        let voteEvent = status
            .withLatestFrom(side) { ($0, $1) }
            .filter { return $0.0 == 13 && $0.1 == Side.judge }
            .flatMap { [unowned self] status in
                self.navigator.toVoteAlert()
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(uid) { ($0, $1) }
            .flatMap { [unowned self] (vote, uid) in
                self.userInfoUsecase.vote(roomID: self.chatRoom.uid, userID: uid, side: vote)
                    .asDriverOnErrorJustComplete()
            }

        let contentEmpty = input.content.map { !$0.isEmpty }

        let canEditable = Driver.combineLatest(status, side) { (status, side) -> Bool in
            guard status >= 2
            else { return true }
            switch side {
            case .agree:
                return [2, 4, 5, 9, 10, 12].contains(status)
            case .disagree:
                return [3, 4, 6, 8, 10, 11].contains(status)
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
            .do(onNext: { [unowned self] in
                self.navigator.toSideMenu(self.chatRoom)
            })

        let sendEvent = input.send
            .withLatestFrom(contentAndUID)
            .map { (content, uid) -> Chat in
                Chat(userID: uid, content: content, date: Date())
            }
            .withLatestFrom(side) {
                var chat: Chat = $0
                chat.side = $1
                return chat
            }
            .flatMap { [unowned self] in
                self.chatsUsecase.send(roomUID: self.chatRoom.uid, chat: $0)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let appear = input.trigger
            .do(onNext: self.navigator.appear)

        let disappear = input.disappear
            .do(onNext: self.navigator.disappear)

        let events = Driver.of(
            voteEvent,
            sideEvent,
            sideMenuEvent,
            sendEvent,
            enterEvent,
            clearSideEvent,
            appear,
            disappear
        )
            .merge()

        return Output(
            chatItems: Driver.of(chatItems, maskingChatItems).merge(),
            userInfos: userInfos,
            sendEnable: canSend,
            noticeHidden: noticeHidden.distinctUntilChanged().asDriverOnErrorJustComplete(),
            notice: remainTime,
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
        let disappear: Driver<Void>
    }
    
    struct Output {
        let chatItems: Driver<[ChatItemViewModel]>
        let userInfos: Driver<[String: UserInfo]>
        let sendEnable: Driver<Bool>
        let noticeHidden: Driver<Bool>
        let notice: Driver<String>
        let editableEnable: Driver<Bool>
        let sendEvent: Driver<Void>
        let events: Driver<Void>
    }

}
