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

    // MARK: properties

    private let chatRoom = ChatRoom(uid: "uid", title: "test", adminUID: "testUID")

    private var mockNavigator: MockAddDiscussionNavigator!
    private var discussionUsecase: MockDiscussionUsecase!
    private var viewModel: AddDiscussionViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockAddDiscussionNavigator()
        self.discussionUsecase = MockDiscussionUsecase()
        self.viewModel = AddDiscussionViewModel(
            chatRoom: self.chatRoom,
            navigator: self.mockNavigator,
            usecase: self.discussionUsecase
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

    func test_토론_제목을_입력하지_않으면_제출할_수_없다() {
        let titleTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(10, "a"),
            .next(20, ""),
            .next(30, "b"),
            .next(40, "")
        ]).asDriverOnErrorJustComplete()

        let exitTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let introTimeTestableDriver: Driver<Int> = self.scheduler.createHotObservable([
            .next(10, 1)
        ]).asDriverOnErrorJustComplete()

        let mainTimeTestableDriver: Driver<Int> = self.scheduler.createHotObservable([
            .next(10, 1)
        ]).asDriverOnErrorJustComplete()

        let conclusionTimeTestableDriver: Driver<Int> = self.scheduler.createHotObservable([
            .next(10, 1)
        ]).asDriverOnErrorJustComplete()

        let dateTestableDriver: Driver<Date> = self.scheduler.createHotObservable([
            .next(10, Date())
        ]).asDriverOnErrorJustComplete()

        let submitTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = AddDiscussionViewModel.Input(
            exitTrigger: exitTriggerTestableDriver,
            title: titleTestableDriver,
            introTime: introTimeTestableDriver,
            mainTime: mainTimeTestableDriver,
            conclusionTime: conclusionTimeTestableDriver,
            date: dateTestableDriver,
            submitTrigger: submitTriggerTestableDriver
        )
        let output = self.viewModel.transform(input: input)

        output.submitEnabled
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

        func toChatRoom() {}

    }

}
