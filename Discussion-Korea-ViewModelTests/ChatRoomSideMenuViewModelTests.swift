//
//  ChatRoomSideMenuViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/26.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ChatRoomSideMenuViewModelTests: XCTestCase {

    // MARK: properties

    private let chatRoom = ChatRoom(uid: "uid", title: "test", adminUID: "testUID")

    private var mockNavigator: MockChatRoomSideMenuNavigator!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var viewModel: ChatRoomSideMenuViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockChatRoomSideMenuNavigator()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.viewModel = ChatRoomSideMenuViewModel(
            chatRoom: self.chatRoom,
            userInfoUsecase: self.userInfoUsecase,
            navigator: self.mockNavigator
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.userInfoUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

}

extension ChatRoomSideMenuViewModelTests {

    final class MockChatRoomSideMenuNavigator: ChatRoomSideMenuNavigator {

        func toChatRoomSideMenu(_ chatRoom: ChatRoom) {}

        func toChatRoomSchedule(_ chatRoom: ChatRoom) {}

    }

}
