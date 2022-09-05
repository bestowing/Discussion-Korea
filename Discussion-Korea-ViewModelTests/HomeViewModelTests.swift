//
//  HomeViewModelTests.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/06/26.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class HomeViewModelTests: XCTestCase {

    // MARK: - properties

    private var mockNavigator: MockHomeNavigator!
    private var userInfoUsecase: MockUserInfoUsecase!
    private var viewModel: HomeViewModel!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // MARK: - methods

    override func setUp() {
        super.setUp()
        self.mockNavigator = MockHomeNavigator()
        self.userInfoUsecase = MockUserInfoUsecase()
        self.viewModel = HomeViewModel(
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

}

extension HomeViewModelTests {

    final class MockHomeNavigator: HomeNavigator {
        func toHome() {}
        func toEnterGame(_ userID: String) {}
        func toChart() {}
        func toLaw() {}
        func toGuide() {}
    }

}
