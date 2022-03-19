//
//  IDManager.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/19.
//

import Foundation

class IDManager {

    static let shared = IDManager()

    private init() {}

    var userID: String {
        return UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
    }

}
