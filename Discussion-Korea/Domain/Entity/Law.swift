//
//  Law.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation

struct Laws {
    let lastUpdated: Date
    let laws: [Law]
}

struct Law {
    let article: Int
    let topic: String
    let contents: String
}
