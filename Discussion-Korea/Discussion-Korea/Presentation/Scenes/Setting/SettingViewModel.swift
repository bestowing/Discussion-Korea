//
//  SettingViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation

final class SettingViewModel: ViewModelType {

    // MARK: properties

    private let navigator: SettingNavigator

    // MARK: - init/deinit

    init(navigator: SettingNavigator) {
        self.navigator = navigator
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        return Output()
    }

}

extension SettingViewModel {

    struct Input {}
    struct Output {}

}
