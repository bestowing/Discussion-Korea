//
//  ChatRoomViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/21.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ChatRoomViewModelTests: XCTestCase {

    // MARK: properties

    private let chatRoom = ChatRoom(uid: "uid", title: "test", adminUID: "testUID")

    private var mockNavigator: MockChatRoomNavigator!
    private var chatsUsecase: MockChatsUsecase!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var discussionUsecase: MockDiscussionUsecase!
    private var viewModel: ChatRoomViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockChatRoomNavigator()
        self.chatsUsecase = MockChatsUsecase()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.discussionUsecase = MockDiscussionUsecase()
        self.viewModel = ChatRoomViewModel(
            uid: "testUID",
            chatRoom: self.chatRoom,
            navigator: self.mockNavigator,
            chatsUsecase: self.chatsUsecase,
            userInfoUsecase: self.userInfoUsecase,
            discussionUsecase: self.discussionUsecase
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.chatsUsecase = nil
        self.userInfoUsecase = nil
        self.discussionUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

    // TODO: userInfos 다 없애고 mask도 없애고 chatItems만 남기기

    func test_토론이_진행중이지_않더라도_내용이_없다면_채팅을_보낼수_없다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, nil),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 0)
        ]).asObservable()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: Driver.just(()),
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.sendEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(250, false)
        ])
    }

    func test_토론이_진행중이지_않더라도_내용이_있다면_채팅을_보낼수_있다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, nil),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 0)
        ]).asObservable()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "내용")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: Driver.just(()),
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.sendEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(250, true)
        ])
    }

    func test_찬성측인_경우_내용이_있어도_반대측_발언시간에는_채팅을_보낼수_없다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .agree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(250, 3),
            .next(260, 6),
            .next(270, 7),
            .next(280, 8),
            .next(290, 11),
            .next(300, 13)
        ]).asObservable()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "내용")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: Driver.just(()),
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable.drive().disposed(by: self.disposeBag)
        output.sendEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(250, false)
        ])
    }

    func test_반대측인_경우_내용이_있어도_찬성측_발언시간에는_채팅을_보낼수_없다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .disagree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(250, 2),
            .next(260, 5),
            .next(270, 7),
            .next(280, 9),
            .next(290, 12),
            .next(300, 13)
        ]).asObservable()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "내용")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: Driver.just(()),
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable.drive().disposed(by: self.disposeBag)
        output.sendEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(250, false)
        ])
    }

    func test_찬성측인_경우_내용이_있고_찬성측_발언시간이라도_발언권이_없으면_채팅을_보낼수_없다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .agree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 3),
            .next(250, 6),
            .next(260, 7),
            .next(270, 8),
            .next(280, 11),
            .next(290, 13)
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "내용")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, false)
        ])
    }

    func test_반대측인_경우_내용이_있고_반대측_발언시간이라도_발언권이_없으면_채팅을_보낼수_없다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .disagree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 2),
            .next(250, 5),
            .next(260, 7),
            .next(270, 9),
            .next(280, 12),
            .next(290, 13)
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let contentTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(250, "내용")
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: contentTestableDriver,
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, false)
        ])
    }

    func test_찬성측인_경우_내용이_있고_찬성측_발언시간이고_발언권이_있으면_채팅을_보낼수_있다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .disagree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, Date(timeInterval: 60, since: Date()))
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 0),
            .next(250, 1),
            .next(260, 3),
            .next(270, 4),
            .next(280, 6),
            .next(290, 8),
            .next(300, 10),
            .next(310, 11)
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: Driver.just(""),
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, true)
        ])
    }

    func test_반대측인_경우_내용이_있고_반대측_발언시간이고_발언권이_있으면_채팅을_보낼수_있다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .disagree),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, Date(timeInterval: 60, since: Date()))
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 0),
            .next(250, 1),
            .next(260, 3),
            .next(270, 4),
            .next(280, 6),
            .next(290, 8),
            .next(300, 10),
            .next(310, 11)
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: Driver.just(""),
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, true)
        ])
    }

    func test_판정단은_토론중에_편집이_불가능하다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .judge),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 2),
            .next(250, 3),
            .next(260, 4),
            .next(270, 5),
            .next(280, 6),
            .next(290, 7),
            .next(300, 8),
            .next(310, 9),
            .next(320, 10),
            .next(330, 11),
            .next(340, 12),
            .next(350, 13),
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: Driver.just(""),
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, false)
        ])
    }

    func test_관람객은_토론중에_편집이_불가능하다() {

        self.userInfoUsecase.roomUserInfoStream = self.scheduler.createHotObservable([
            .next(235, .observer),
            .completed(237)
        ]).asObservable()

        self.discussionUsecase.myRemainTimeStream = self.scheduler.createHotObservable([
            .next(240, nil)
        ]).asObservable()

        self.discussionUsecase.statusStream = self.scheduler.createHotObservable([
            .next(240, 2),
            .next(250, 3),
            .next(260, 4),
            .next(270, 5),
            .next(280, 6),
            .next(290, 7),
            .next(300, 8),
            .next(310, 9),
            .next(320, 10),
            .next(330, 11),
            .next(340, 12),
            .next(350, 13),
        ]).asObservable()

        let triggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(210, ())
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ChatRoomViewModel.Input(
            trigger: triggerTestableDriver,
            bottomScrolled: Driver.just(false),
            previewTouched: Driver.just(()),
            send: Driver.just(()),
            menu: Driver.just(()),
            content: Driver.just(""),
            disappear: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.editableEnable
            .drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(240, false)
        ])
    }

}

extension ChatRoomViewModelTests {

    final class MockChatRoomNavigator: ChatRoomNavigator {

        let enterAlertStream: PublishSubject<Bool>
        let sideAlertStream: PublishSubject<Side>
        let voteAlertStream: PublishSubject<Side>

        init() {
            self.enterAlertStream = PublishSubject<Bool>.init()
            self.sideAlertStream = PublishSubject<Side>.init()
            self.voteAlertStream = PublishSubject<Side>.init()
        }

        func toChatRoom(_ uid: String, _ chatRoom: ChatRoom) {}

        func toSideMenu(_ uid: String, _ chatRoom: ChatRoom) {}

        func toEnterAlert() -> Observable<Bool> {
            self.enterAlertStream
        }

        func toSideAlert() -> Observable<Side> {
            self.sideAlertStream
        }

        func toVoteAlert() -> Observable<Side> {
            self.voteAlertStream
        }

        func toDiscussionResultAlert(result: DiscussionResult) {}

        func appear() {}

        func disappear() {}

    }

}
