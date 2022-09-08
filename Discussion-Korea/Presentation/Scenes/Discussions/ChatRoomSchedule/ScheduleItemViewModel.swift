//
//  ScheduleItemViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import Foundation

final class ScheduleItemViewModel {

    // MARK: - properties

    private let discussion: Discussion

    var topicString: String {
        "\(self.discussion.topic)"
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd HH:mm에 시작"
        return "\(formatter.string(from: self.discussion.date))"
    }

    // MARK: - init/deinit

    init(with discussion: Discussion) {
        self.discussion = discussion
    }

}
