//
//  ChatRoomListViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/26.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ChatRoomListViewModelTests: XCTestCase {

    // MARK: properties

    private var mockNavigator: MockChatRoomListNavigator!
    private var chatRoomUsecase: MockChatRoomUsecase!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var viewModel: ChatRoomListViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockChatRoomListNavigator()
        self.chatRoomUsecase = MockChatRoomUsecase()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.viewModel = ChatRoomListViewModel(
            navigator: self.mockNavigator,
            chatRoomsUsecase: self.chatRoomUsecase,
            userInfoUsecase: self.userInfoUsecase
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.chatRoomUsecase = nil
        self.userInfoUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

}

extension ChatRoomListViewModelTests {

    final class MockChatRoomListNavigator: ChatRoomListNavigator {

        func toChatRoomList() {}

        func toChatRoom(_ uid: String, _ chatRoom: ChatRoom) {}

        func toAddChatRoom(_ userID: String) {}

    }

}
