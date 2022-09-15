//
//  ChatRoomFindViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/15.
//

import RxCocoa

final class ChatRoomFindViewModel: ViewModelType {

    // MARK: - properties

    private let userID: String
    private let navigator: ChatRoomFindNavigator
    private let chatRoomsUsecase: ChatRoomsUsecase
    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(userID: String,
         navigator: ChatRoomFindNavigator,
         chatRoomsUsecase: ChatRoomsUsecase,
         userInfoUsecase: UserInfoUsecase) {
        self.userID = userID
        self.navigator = navigator
        self.chatRoomsUsecase = chatRoomsUsecase
        self.userInfoUsecase = userInfoUsecase
    }

    deinit {
        print("🗑", self)
    }

    func transform(input: Input) -> Output {
        return Output()
    }

}

extension ChatRoomFindViewModel {

    struct Input {
        
    }

    struct Output {
//        let chatRooms: Driver<[ChatRoom]>
    }

}
