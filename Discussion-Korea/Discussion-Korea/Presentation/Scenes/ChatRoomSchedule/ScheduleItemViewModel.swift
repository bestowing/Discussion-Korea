//
//  ScheduleItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation

final class ScheduleItemViewModel {

    var discussion: Discussion

    var topicString: String {
        "주제: \(self.discussion.topic)"
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 H시 m분에 예약됨"
        return "\(formatter.string(from: self.discussion.date))"
    }

    var durationString: String {
        "\(self.discussion.durations.reduce(0, +))분동안 진행"
    }

    init(with discussion: Discussion) {
        self.discussion = discussion
    }

}
