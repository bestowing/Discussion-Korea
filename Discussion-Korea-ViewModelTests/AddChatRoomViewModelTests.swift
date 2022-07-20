//
//  AddChatRoomViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/08.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class AddChatRoomViewModelTests: XCTestCase {

    // MARK: properties

    private let userId = "test"

    private var mockNavigator: MockAddChatRoomNavigator!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var chatRoomUsecase: MockChatRoomUsecase!
    private var viewModel: AddChatRoomViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockAddChatRoomNavigator()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.chatRoomUsecase = MockChatRoomUsecase()
        self.viewModel = AddChatRoomViewModel(
            userID: self.userId,
            navigator: self.mockNavigator,
            userInfoUsecase: self.userInfoUsecase,
            chatRoomUsecase: self.chatRoomUsecase
        )
        self.disposeBag = DisposeBag()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockNavigator = nil
        self.userInfoUsecase = nil
        self.chatRoomUsecase = nil
        self.viewModel = nil
        self.disposeBag = nil
        self.scheduler = nil
        super.tearDown()
    }

    func test_제목을_입력하지_않으면_제출할_수_없다() {
        let titleTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(10, "a"),
            .next(20, ""),
            .next(30, "b"),
            .next(40, "")
        ]).asDriverOnErrorJustComplete()

        let imageTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([
            .next(10, ())
        ]).asDriverOnErrorJustComplete()

        let exitTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let submitTriggerTestableDriver: Driver<Void> = self.scheduler.createHotObservable([])
            .asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = AddChatRoomViewModel.Input(
            title: titleTestableDriver,
            imageTrigger: imageTriggerTestableDriver,
            exitTrigger: exitTriggerTestableDriver,
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

    // TODO: 채팅방 최대 길이에 대한 테스트 추가하기

}

extension AddChatRoomViewModelTests {

    final class MockAddChatRoomNavigator: AddChatRoomNavigator {

        func toAddChatRoom(_ userID: String) {}

        func toChatRoomList() {}

        func toSettingAppAlert() {}

        func toImagePicker() -> Observable<URL?> {
            return Observable<URL?>.create { _ in
                return Disposables.create()
            }
        }

        func toErrorAlert(_ error: Error) {}
        
    }

}
