//
//  SideManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/16.
//

import Combine
import Foundation

final class SideManager {

    @Published private var agrees: [String] = []
    @Published private var disagrees: [String] = []
    @Published private var judges: [String] = []
    @Published private var observers: [String] = []

    func isDone() -> AnyPublisher<Bool, Never> {
        self.$agrees
            .combineLatest($disagrees, $judges)
            .map {
                // FIXME: 판정단은 없어도 되는 상태
                return !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func appendAgree(id: String) {
        self.agrees.append(id)
    }

    func appendDisagree(id: String) {
        self.disagrees.append(id)
    }

    func appendJudge(id: String) {
        self.judges.append(id)
    }

    func appendObserver(id: String) {
        self.observers.append(id)
    }

    func endDiscussion() {
        self.agrees = []
        self.disagrees = []
        self.judges = []
        self.observers = []
    }

}
