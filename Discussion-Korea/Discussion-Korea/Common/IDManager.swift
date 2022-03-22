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

    func userID() -> String {
        let key = "userID"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }

}
