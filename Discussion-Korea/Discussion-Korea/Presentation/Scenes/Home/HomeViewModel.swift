//
//  HomeViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation
import RxCocoa

final class HomeViewModel: ViewModelType {

    // MARK: properties

    private let navigator: HomeNavigator

    // MARK: - init/deinit

    init(navigator: HomeNavigator) {
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

extension HomeViewModel {

    struct Input {}
    
    struct Output {}

}
