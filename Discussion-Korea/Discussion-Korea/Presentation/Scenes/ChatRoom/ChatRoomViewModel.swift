//
//  ChatRoomViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class ChatRoomViewModel: ViewModelType {

    private let chatsUsecase: ChatsUsecase
    private let userInfoUsecase: UserInfoUsecase
    private let navigator: ChatRoomNavigator

    init(chatsUsecase: ChatsUsecase,
         userInfoUsecase: UserInfoUsecase,
         navigator: ChatRoomNavigator) {
        self.chatsUsecase = chatsUsecase
        self.userInfoUsecase = userInfoUsecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {

        let uid = self.userInfoUsecase
            .uid()
            .asDriverOnErrorJustComplete()

        let enterEvent = uid
            .flatMap { [unowned self] uid in
                self.userInfoUsecase
                    .userInfo(room: 1, with: uid)
                    .asDriverOnErrorJustComplete()
            }
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
            .flatMap { [unowned self] in
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
            .flatMap { [unowned self] in
                self.chatsUsecase.connect(room: 1)
                    .asDriverOnErrorJustComplete()
                    .do(onNext: { print($0) })
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

        let canSend = input.content.map { !$0.isEmpty }

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

        return Output(chatItems: chatItems, userInfos: userInfos, sendEnable: canSend, sideMenuEvent: sideMenuEvent, sendEvent: sendEvent, enterEvent: enterEvent)
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
        let sideMenuEvent: Driver<Void>
        let sendEvent: Driver<Void>
        let enterEvent: Driver<Void>
    }

}
