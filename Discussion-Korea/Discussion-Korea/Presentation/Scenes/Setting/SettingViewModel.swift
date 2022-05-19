//
//  SettingViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import Foundation

final class SettingViewModel: ViewModelType {

    private let navigator: SettingNavigator

    init(navigator: SettingNavigator) {
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        return Output()
    }

}

extension SettingViewModel {

    struct Input {}
    struct Output {}

}
