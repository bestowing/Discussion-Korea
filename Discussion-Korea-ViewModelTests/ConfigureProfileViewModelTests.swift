//
//  EnterGuestViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/26.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ConfigureProfileViewModelTests: XCTestCase {

    // MARK: - properties

    private let userId = "test"
    private let nickname = "testNickname"

    private var mockNavigator: MockEditProfileNavigator!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var viewModel: ConfigureProfileViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockEditProfileNavigator()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.viewModel = ConfigureProfileViewModel(
            userID: self.userId,
            nickname: self.nickname,
            profileURL: nil,
            navigator: self.mockNavigator,
            userInfoUsecase: self.userInfoUsecase
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

    func test_유효한_닉네임을_입력하지_않으면_제출할_수_없다() {
        self.userInfoUsecase.nicknameValidStream = self.scheduler.createHotObservable([
            .next(220, FormResult.failure("")),
            .completed(221)
        ]).asObservable()

        let nicknameTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(210, ""),
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ConfigureProfileViewModel.Input(
            nickname: nicknameTestableDriver,
            exitTrigger: Driver.just(()),
            imageTrigger: Driver.just(()),
            submitTrigger: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.submitEnable.drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(220, false)
        ])
    }

    func test_유효한_닉네임을_입력하면_제출할_수_있다() {
        self.userInfoUsecase.nicknameValidStream = self.scheduler.createHotObservable([
            .next(220, FormResult.success),
            .completed(221)
        ]).asObservable()

        let nicknameTestableDriver: Driver<String> = self.scheduler.createHotObservable([
            .next(210, "닉네임"),
        ]).asDriverOnErrorJustComplete()

        let testableObserver = self.scheduler.createObserver(Bool.self)

        let input = ConfigureProfileViewModel.Input(
            nickname: nicknameTestableDriver,
            exitTrigger: Driver.just(()),
            imageTrigger: Driver.just(()),
            submitTrigger: Driver.just(())
        )
        let output = self.viewModel.transform(input: input)

        output.submitEnable.drive(testableObserver)
            .disposed(by: self.disposeBag)

        self.scheduler.start()

        XCTAssertEqual(testableObserver.events, [
            .next(220, true)
        ])
    }

    // TODO: 닉네임 최대 길이에 대한 테스트 추가하기

}

extension ConfigureProfileViewModelTests {

    final class MockEditProfileNavigator: ConfigureProfileNavigator {

        func toConfigureProfile(_ userID: String, _ nickname: String?, _ profileURL: URL?) {}
        func dismiss() {}
        func toSettingAppAlert() {}

        func toImagePicker() -> Observable<URL?> {
            return Observable<URL?>.create { _ in
                return Disposables.create()
            }
        }

        func toErrorAlert(_ error: Error) {}

    }

}
