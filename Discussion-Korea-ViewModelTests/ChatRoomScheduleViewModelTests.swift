//
//  ChatRoomScheduleViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/26.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ChatRoomScheduleViewModelTests: XCTestCase {

    // MARK: - properties

    private let userID = "testUID"
    private let chatRoom = ChatRoom(uid: "uid", title: "test", adminUID: "testUID")

    private var mockNavigator: MockChatRoomScheduleNavigator!
    private var discussionUsecase: MockDiscussionUsecase!
    private var viewModel: ChatRoomScheduleViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockChatRoomScheduleNavigator()
        self.discussionUsecase = MockDiscussionUsecase()
        self.viewModel = ChatRoomScheduleViewModel(
            userID: self.userID,
            chatRoom: self.chatRoom,
            usecase: self.discussionUsecase,
            navigator: self.mockNavigator
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.discussionUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

}

extension ChatRoomScheduleViewModelTests {

    final class MockChatRoomScheduleNavigator: ChatRoomScheduleNavigator {
        func toChatRoomSchedule(_ userID: String, _ chatRoom: ChatRoom) {}
        func toAddDiscussion(_ chatRoom: ChatRoom) {}
        func toChatRoom() {}
    }

}

