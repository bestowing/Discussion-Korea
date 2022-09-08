//
//  AddDiscussionViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/21.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class AddDiscussionViewModelTests: XCTestCase {

    // MARK: - properties

    private let chatRoom = ChatRoom(uid: "uid", title: "test", adminUID: "testUID")

    private var mockNavigator: MockAddDiscussionNavigator!
    private var builderUsecase: MockBuilderUsecase!
    private var discussionUsecase: MockDiscussionUsecase!
    private var viewModel: AddDiscussionViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockAddDiscussionNavigator()
        self.builderUsecase = MockBuilderUsecase()
        self.discussionUsecase = MockDiscussionUsecase()
        self.viewModel = AddDiscussionViewModel(
            chatRoom: self.chatRoom,
            navigator: self.mockNavigator,
            builderUsecase: self.builderUsecase,
            discussionUsecase: self.discussionUsecase
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.builderUsecase = nil
        self.discussionUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

    func test_유효한_날짜를_입력해도_토론_제목을_입력하지_않으면_넘어갈_수_없다() {
        let titleTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(10, "a"),
            .next(20, ""),
            .next(30, "b"),
            .next(40, "")
        ]).asDriverOnErrorJustComplete()

        let exitTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let dateTestableDriver: Driver<Date> = self.scheduler.createHotObservable([
            .next(10, Date().addingTimeInterval(5000))
        ]).asDriverOnErrorJustComplete()

        let nextTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = AddDiscussionViewModel.Input(
            exitTrigger: exitTriggerTestableDriver,
            title: titleTestableDriver,
            date: dateTestableDriver,
            nextTrigger: nextTriggerTestableDriver
        )
        let output = self.viewModel.transform(input: input)

        output.nextEnabled
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(10, true),
            .next(20, false),
            .next(30, true),
            .next(40, false)
        ])
    }

    // TODO: 토론 제목 최대 길이에 대한 테스트 추가하기

}

extension AddDiscussionViewModelTests {

    final class MockAddDiscussionNavigator: AddDiscussionNavigator {
        func toAddDiscussion(_ chatRoom: ChatRoom) {}
        func toSetDiscussionTime(_ chatRoom: ChatRoom) {}
        func toChatRoom() {}
    }

}
