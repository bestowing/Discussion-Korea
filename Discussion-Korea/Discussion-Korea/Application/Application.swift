//
//  Application.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Foundation
import Domain

final class Application {

    static let shared = Application()

    private let firebaseUseCaseProvider: UsecaseProvider

    private init() {
        self.firebaseUseCaseProvider = UsecaseProvider()
    }

}
