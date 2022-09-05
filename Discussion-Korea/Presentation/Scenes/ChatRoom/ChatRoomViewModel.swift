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
    private let factory: ChatItemViewModelFactory

    private let chatsUsecase: ChatsUsecase
    private let chatRoomsUsecase: ChatRoomsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let discussionUsecase: DiscussionUsecase

    // MARK: - init/deinit

    init(uid: String,
         chatRoom: ChatRoom,
         navigator: ChatRoomNavigator,
         factory: ChatItemViewModelFactory,
         chatsUsecase: ChatsUsecase,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase,
         discussionUsecase: DiscussionUsecase) {
        self.uid = uid
        self.chatRoom = chatRoom
        self.navigator = navigator
        self.factory = factory
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

        let isFetchingLimited = PublishSubject<Bool>()
        let chatItems = PublishSubject<[ChatItemViewModel]>()
        let previewItem = PublishSubject<ChatItemViewModel?>()

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

        let initialization = userInfos
            .flatMapFirst { [unowned self] _ in
                self.chatsUsecase.chats(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(userInfos) { ($0, $1) }
            .map { (chats, userInfos) -> [Chat] in
                return chats.map { chat in
                    var chat = chat
                    chat.nickName = userInfos[chat.userID]?.nickname
                    chat.profileURL = userInfos[chat.userID]?.profileURL
                    return chat
                }
            }
            .map { chats -> [ChatItemViewModel] in
                var viewModels = [ChatItemViewModel]()
                for (index, chat) in chats.enumerated() {
                    if let prevChat = chats[safe: index - 1],
                       prevChat.userID == chat.userID,
                       let lastDate = prevChat.date,
                       let currentDate = chat.date,
                       Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                        viewModels[index - 1].chat.date = nil
                    }
                    viewModels.append(
                        self.factory.create(
                            prevChat: chats[safe: index - 1], chat: chat, isEditing: false
                        )
                    )
                }
                return viewModels
            }

        let initializationEvent = initialization
            .do(onNext: {
                isFetchingLimited.onNext($0.isEmpty)
                chatItems.onNext($0)
            })
            .mapToVoid()

        let newChatsEvent = initialization
            .flatMap { [unowned self] viewModels in
                self.chatsUsecase.receiveNewChats(roomUID: self.chatRoom.uid, after: viewModels.last?.chat.uid)
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(userInfos) { ($0, $1) }
            .map { (chat, userInfos) -> Chat in
                var chat = chat
                chat.nickName = userInfos[chat.userID]?.nickname
                chat.profileURL = userInfos[chat.userID]?.profileURL
                return chat
            }
            .withLatestFrom(chatItems.asDriverOnErrorJustComplete()) { ($0, $1) }
            .do(onNext: { [unowned self] chat, viewModels in
                var viewModels = viewModels
                if var last = viewModels.last,
                   last.chat.userID == chat.userID,
                   let lastDate = last.chat.date,
                   let currentDate = chat.date,
                   Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                    last.chat.date = nil
                    viewModels[viewModels.endIndex - 1] = last
                }
                let newViewModel = self.factory.create(
                    prevChat: viewModels.last?.chat, chat: chat, isEditing: false
                )
                viewModels.append(newViewModel)
                chatItems.onNext(viewModels)
                previewItem.onNext(newViewModel)
            })
            .mapToVoid()

        let loadMoreEvent = input.loadMoreTrigger
            .withLatestFrom(isFetchingLimited.asDriverOnErrorJustComplete())
            .filter { !$0 }
            .withLatestFrom(chatItems.asDriverOnErrorJustComplete())
            .compactMap { $0.first?.chat.uid }
            .flatMapLatest { [unowned self] uid in
                self.chatsUsecase.loadMoreChats(roomUID: self.chatRoom.uid, before: uid)
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(userInfos) { ($0, $1) }
            .map { (chats, userInfos) -> [Chat] in
                return chats.map { chat in
                    var chat = chat
                    chat.nickName = userInfos[chat.userID]?.nickname
                    chat.profileURL = userInfos[chat.userID]?.profileURL
                    return chat
                }
            }
            .withLatestFrom(chatItems.asDriverOnErrorJustComplete()) { ($0, $1) }
            .do(onNext: { [unowned self] chats, viewModels in
                var viewModels = viewModels
                var newViewModels = [ChatItemViewModel]()
                for (index, chat) in chats.enumerated() {
                    if let prevChat = chats[safe: index - 1],
                       prevChat.userID == chat.userID,
                       let lastDate = prevChat.date,
                       let currentDate = chat.date,
                       Int(currentDate.timeIntervalSince(lastDate)) < 60 {
                        newViewModels[index - 1].chat.date = nil
                    }
                    newViewModels.append(
                        self.factory.create(
                            prevChat: chats[safe: index - 1], chat: chat, isEditing: false
                        )
                    )
                }
                if let firstChat = viewModels.first?.chat,
                   let lastChat = chats.last,
                   firstChat.userID == lastChat.userID,
                   let firstDate = firstChat.date,
                   let lastDate = lastChat.date,
                   Int(lastDate.timeIntervalSince(firstDate)) < 60 {
                    viewModels[viewModels.endIndex - 1].chat.date = nil
                }
                isFetchingLimited.onNext(newViewModels.isEmpty)
                chatItems.onNext(newViewModels + viewModels)
            })
            .mapToVoid()

        let maskingEvent = input.trigger
            .flatMapFirst { [unowned self] in
                self.chatsUsecase.masking(roomUID: self.chatRoom.uid)
                    .asDriverOnErrorJustComplete()
            }
            .withLatestFrom(chatItems.asDriverOnErrorJustComplete()) { ($0, $1) }
            .do(onNext: { uid, viewModels in
                if let item = viewModels.firstIndex(where: { $0.chat.uid! == uid }) {
                    var viewModels = viewModels
                    viewModels[item].chat.toxic = true
                    chatItems.onNext(viewModels)
                }
            })
            .mapToVoid()

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
                return self.factory.create(prevChat: nil, chat: chat, isEditing: true)
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

        let previewCheckEvent = input.bottomScrolled
            .do(onNext: {
                if $0 { previewItem.onNext(nil) }
            })
            .mapToVoid()

        let preview = previewItem
            .withLatestFrom(input.bottomScrolled) { ($0, $1) }
            .map { (model, scrolled) -> ChatItemViewModel? in
                return scrolled ? nil : model
            }
            .asDriverOnErrorJustComplete()

        let appear = input.trigger
            .do(onNext: self.navigator.appear)

        let disappear = input.disappear
            .do(onNext: self.navigator.disappear)

        let events = Driver.of(
            initializationEvent,
            newChatsEvent,
            maskingEvent,
            loadMoreEvent,
            voteEvent,
            selectSideEvent,
            sideMenuEvent,
            sendEvent,
            enterEvent,
            clearSideEvent,
            resultEvent,
            previewCheckEvent,
            appear,
            disappear,
            writingEvent
        )
            .merge()

        return Output(
            myRemainTime: myRemainTimeString,
            remainTime: remainTime,
            noticeContent: noticeContent,
            chatItems: chatItems
                .map { [ChatSectionModel(model: "", items: $0)] }
                .asDriverOnErrorJustComplete()
                .startWith([]),
            toBottom: input.previewTouched,
            sendEnable: canSend,
            preview: preview
                .startWith(nil),
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
        let loadMoreTrigger: Driver<Void>
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
        let chatItems: Driver<[ChatSectionModel]>
        let toBottom: Driver<Void>
        let sendEnable: Driver<Bool>
        let preview: Driver<ChatItemViewModel?>
        let realTimeChat: Driver<ChatItemViewModel?>
        let editableEnable: Driver<Bool>
        let sendEvent: Driver<Void>
        let events: Driver<Void>
    }

}

extension Array {

    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }

}
