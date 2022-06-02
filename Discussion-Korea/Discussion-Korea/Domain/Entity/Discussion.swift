//
//  Discussion.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation

struct Discussion {

    let uid: String?
    let date: Date
    let durations: [Int]
    let topic: String

    init(uid: String, date: Date, durations: [Int], topic: String) {
        self.uid = uid
        self.date = date
        self.durations = durations
        self.topic = topic
    }

    init(date: Date, durations: [Int], topic: String) {
        self.uid = nil
        self.date = date
        self.durations = durations
        self.topic = topic
    }

}
