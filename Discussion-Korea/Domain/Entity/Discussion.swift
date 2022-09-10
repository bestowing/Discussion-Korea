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
    let isFulltime: Bool

    init(uid: String, date: Date, durations: [Int], topic: String, isFulltime: Bool) {
        self.uid = uid
        self.date = date
        self.durations = durations
        self.topic = topic
        self.isFulltime = isFulltime
    }

    init(date: Date, durations: [Int], topic: String, isFulltime: Bool) {
        self.uid = nil
        self.date = date
        self.durations = durations
        self.topic = topic
        self.isFulltime = isFulltime
    }

}
