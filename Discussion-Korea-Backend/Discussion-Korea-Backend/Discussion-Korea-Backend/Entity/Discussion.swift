//
//  Discussion.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/16.
//

import Foundation

struct Discussion {

    let uid: String?
    let date: Date
    let durations: [Double]
    let topic: String

    init(uid: String, date: Date, durations: [Double], topic: String) {
        self.uid = uid
        self.date = date
        self.durations = durations
        self.topic = topic
    }

    init(date: Date, durations: [Double], topic: String) {
        self.uid = nil
        self.date = date
        self.durations = durations
        self.topic = topic
    }

}
