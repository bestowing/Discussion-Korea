//
//  HomeViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Foundation
import RxCocoa

final class HomeViewModel: ViewModelType {

    private let navigator: HomeNavigator

    struct Input {
        let enterChatRoomTrigger: Driver<Void>
    }
    
    struct Output {
        let events: Driver<Void>
    }

    init(navigator: HomeNavigator) {
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let enter = input.enterChatRoomTrigger
            .do(onNext: navigator.toChatRoom)

        return Output(events: enter)
    }

}
