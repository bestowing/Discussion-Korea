//
//  ScheduleItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation

final class ScheduleItemViewModel {

    // MARK: - properties

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
        guard self.discussion.durations.count >= 3
        else { return "" }
        let restTime = 10
        let voteTime = 1
        let duration = self.discussion.durations[0] * 4 + self.discussion.durations[1] * 2 + self.discussion.durations[2] * 4 + restTime + voteTime
        return "\(duration)분동안 진행"
    }

    // MARK: - init/deinit

    init(with discussion: Discussion) {
        self.discussion = discussion
    }

}
