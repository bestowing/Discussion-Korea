//
//  ChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa
import RxSwift

enum NicknameError: Error {
    case unknownUID
}

final class ChatRoomViewModel: ViewModelType {

    // MARK: properties

    private let uid: String
    private let chatRoom: ChatRoom
    private let navigator: ChatRoomNavigator

    private let chatsUsecase: ChatsUsecase
    private let chatRoomsUsecase: ChatRoomsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let discussionUsecase: DiscussionUsecase

    // MARK: - init/deinit

    init(uid: String,
         chatRoom: ChatRoom,
         navigator: ChatRoomNavigator,
         chatsUsecase: ChatsUsecase,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase,
         discussionUsecase: DiscussionUsecase) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.chatsUsecase = chatsUsecase
        self.chatRoomsUsecase = chatRoomsUsecase
        self.userInfoUsecase = userInfoUsecase
        self.discussionUsecase = discussionUsecase
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {

        let myRemainTime = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.remainTime(userID: self.uid, roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let myRemainTimeString: Driver<String> = myRemainTime
            .compactMap { date -> Int? in
                guard let date = date else { return nil }
                let timeInterval = date.timeIntervalSince(Date())
                return abs(Int(timeInterval))
            }
            .flatMapLatest { remainSeconds in
                Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                    .map { remainSeconds - $0 }
                    .take(until: { $0 == -2 })
                    .asDriverOnErrorJustComplete()
            }
            .map {
                if $0 == -1 { return "" }
                return "\(String(format: "%02d", $0 / 60)):\(String(format: "%02d", $0 % 60))"
            }

        let remainTime: Driver<String> = input.trigger
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
                    .take(until: { $0 == -2 })
                    .asDriverOnErrorJustComplete()
            }
            .map {
                if $0 == -1 { return "" }
                return "\(String(format: "%02d", $0 / 60)):\(String(format: "%02d", $0 % 60))"
            }

        let enterEvent: Driver<Void> = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatRoomsUsecase.isFirstEntering(userID: self.uid, chatRoomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
                    .filter { $0 }
            }
            .flatMap { [unowned self] _ in
                self.navigator.toEnterAlert()
                    .asDriverOnErrorJustComplete()
            }
            .flatMap { [unowned self] _ in
                self.userInfoUsecase.add(roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        let resultEvent: Driver<Void> = input.trigger
            .flatMapFirst { [unowned self] _ in
                self.discussionUsecase.discussionResult(userID: self.uid, chatRoomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: self.navigator.toDiscussionResultAlert)
            .mapToVoid()

        let userInfos = input.trigger
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.userInfos(roomID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let remainChats = userInfos
            .flatMapFirst { [unowned self] _ in
                self.chatsUsecase.chats(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let chats = remainChats
        // FIXME: 고치기
            .flatMapFirst { [unowned self] remains in
                self.chatsUsecase.connect(roomUID: self.chatRoom.uid, after: nil)
                    .asDriverOnErrorJustComplete()
            }

        let chatItems = chats
            .withLatestFrom(userInfos) { ($0, $1) }
            .scan([ChatItemViewModel]()) { (viewModels, args) in
                var chat = args.0
                let uid = self.uid
                let userInfos = args.1
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
                } else if chat.userID == "bot" {
                    if let last = viewModels.last,
                       last.chat.userID == chat.userID {
                        newItemViewModel = SerialBotChatItemViewModel(with: chat)
                    } else {
                        newItemViewModel = BotChatItemViewModel(with: chat)
                    }
                } else {
                    if let last = viewModels.last,
                       last.chat.userID == chat.userID {
                        newItemViewModel = SerialOtherChatItemViewModel(with: chat)
                    } else {
                        newItemViewModel = OtherChatItemViewModel(with: chat)
                    }
                }
                return [newItemViewModel]
            }
            .map { $0.first! }

        let masking = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatsUsecase.masking(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let status = input.trigger
            .flatMapFirst { [unowned self] in
                self.discussionUsecase.status(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }

        let side = input.trigger
            .flatMapFirst { [unowned self] in
                self.userInfoUsecase.userInfo(roomID: self.chatRoom.uid, with: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let selectSideEvent = status
            .filter { return $0 == 1 }
            .withLatestFrom(side) { $1 }
            .filter { $0 == nil }
            .flatMap { [unowned self] _ in
                self.navigator.toSideAlert()
                    .asDriverOnErrorJustComplete()
            }
            .flatMap { [unowned self] side in
                self.userInfoUsecase.add(roomID: self.chatRoom.uid, userID: self.uid, side: side)
                    .asDriverOnErrorJustComplete()
            }

        let clearSideEvent = status
            .filter { return $0 == 0 }
            .flatMap { [unowned self] _ in
                self.userInfoUsecase.clearSide(roomID: self.chatRoom.uid, userID: self.uid)
                    .asDriverOnErrorJustComplete()
            }

        let voteEvent = status
            .withLatestFrom(side) { ($0, $1) }
            .filter { return $0.0 == 13 && $0.1 == Side.judge }
            .flatMap { [unowned self] status in
                self.navigator.toVoteAlert()
                    .asDriverOnErrorJustComplete()
            }
            .flatMap { [unowned self] vote in
                self.userInfoUsecase.vote(roomID: self.chatRoom.uid, userID: self.uid, side: vote)
                    .asDriverOnErrorJustComplete()
            }

        let hasSpeakRight: Driver<Bool> = Driver.combineLatest(status, myRemainTime)
            .map { status, date in
                if status < 2 {
                    return true
                }
                return date != nil
            }
            .distinctUntilChanged()

        let speakableSide: Driver<Bool> = Driver.combineLatest(status, side)
            .map { status, side -> Bool in
                guard status >= 2 else { return true }
                switch side {
                case .agree:
                    return [2, 4, 5, 9, 10, 12].contains(status)
                case .disagree:
                    return [3, 4, 6, 8, 10, 11].contains(status)
                default:
                    return false
                }
            }
            .distinctUntilChanged()

        let canEditable: Driver<Bool> = Driver.combineLatest(hasSpeakRight, speakableSide) { $0 && $1 }

        let noticeContent = status.map { status -> String in
            // TODO: 하드코딩 고치기
            switch status {
            case 1:
                return "토론 시작 대기"
            case 2:
                return "찬성측의 입론 시간"
            case 3:
                return "반대측의 입론 시간"
            case 4:
                return "자유토론 시간"
            case 5:
                return "찬성측의 결론 시간"
            case 6:
                return "반대측의 결론 시간"
            case 7:
                return "쉬는 시간"
            case 8:
                return "반대측의 입론 시간"
            case 9:
                return "찬성측의 입론 시간"
            case 10:
                return "자유토론 시간"
            case 11:
                return "반대측의 결론 시간"
            case 12:
                return "찬성측의 결론 시간"
            case 13:
                return "투표 시간"
            default:
                return ""
            }
        }

        let canSend = Driver.combineLatest(canEditable, input.content) {
            return $0 && !$1.isEmpty
        }

        let sideMenuEvent = input.menu
            .do(onNext: { [unowned self] in
                self.navigator.toSideMenu(self.uid, self.chatRoom)
            })

        let writingChat = input.trigger
            .flatMapFirst { [unowned self] _ in
                self.chatsUsecase.getEditing(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(userInfos) { ($0, $1) }
            .map { chat, userInfos -> ChatItemViewModel? in
                guard var chat = chat else { return nil }
                chat.nickName = userInfos[chat.userID]?.nickname
                chat.profileURL = userInfos[chat.userID]?.profileURL
                return WritingChatItemViewModel(with: chat)
            }

        let writingEvent: Driver<Void> = input.content
            .throttle(.milliseconds(1500))
            .distinctUntilChanged()
            .map { [unowned self] content -> Chat in
                Chat(userID: self.uid, content: content, date: Date())
            }
            .withLatestFrom(side) { (chat, side) -> Chat in
                var chat = chat
                chat.side = side
                return chat
            }
            .filter { $0.side != nil }
            .withLatestFrom(status) { ($0, $1) }
            .filter { $1 != 1 && $1 != 4 && $1 != 10 }
            .flatMap { [unowned self] (chat, status) -> Driver<Void> in
                return self.chatsUsecase.edit(roomUID: self.chatRoom.uid, chat: chat)
                    .asDriverOnErrorJustComplete()
            }

        let sendEvent = input.send
            .withLatestFrom(input.content)
            .map { [unowned self] content -> Chat in
                Chat(userID: self.uid, content: content, date: Date())
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
            selectSideEvent,
            sideMenuEvent,
            sendEvent,
            enterEvent,
            clearSideEvent,
            resultEvent,
            appear,
            disappear,
            writingEvent
        )
            .merge()

        return Output(
            myRemainTime: myRemainTimeString,
            remainTime: remainTime,
            noticeContent: noticeContent,
            chatItems: chatItems,
            mask: masking,
            toBottom: input.previewTouched,
            sendEnable: canSend,
            isPreviewHidden: input.bottomScrolled,
            realTimeChat: writingChat,
            editableEnable: canEditable,
            sendEvent: sendEvent,
            events: events
        )
    }

}

extension ChatRoomViewModel {

    struct Input {
        let trigger: Driver<Void>
        let bottomScrolled: Driver<Bool>
        let previewTouched: Driver<Void>
        let send: Driver<Void>
        let menu: Driver<Void>
        let content: Driver<String>
        let disappear: Driver<Void>
    }

    struct Output {
        let myRemainTime: Driver<String>
        let remainTime: Driver<String>
        let noticeContent: Driver<String>
        let chatItems: Driver<ChatItemViewModel>
        let mask: Driver<String>
        let toBottom: Driver<Void>
        let sendEnable: Driver<Bool>
        let isPreviewHidden: Driver<Bool>
        let realTimeChat: Driver<ChatItemViewModel?>
        let editableEnable: Driver<Bool>
        let sendEvent: Driver<Void>
        let events: Driver<Void>
    }

}
