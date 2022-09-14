//
//  Action.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/14.
//

import Foundation

final class Action: NSObject {

    // MARK: - properties

    private let _action: () -> ()

    // MARK: - init/deinit

    init(action: @escaping () -> ()) {
        self._action = action
        super.init()
    }

    // MARK: - methods

    @objc func performAction() {
        self._action()
    }

}
