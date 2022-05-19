//
//  HomeViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class HomeViewModel: ViewModelType {

    private let navigator: HomeNavigator

    struct Input {}
    
    struct Output {}

    init(navigator: HomeNavigator) {
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        return Output()
    }

}
