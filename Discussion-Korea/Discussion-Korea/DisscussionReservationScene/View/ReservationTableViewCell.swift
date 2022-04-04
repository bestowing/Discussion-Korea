//
//  ReservationTableViewCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/04.
//

import UIKit

final class ReservationTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var topicLabel: UILabel!

    private var event: (() -> Void)?

    func bind(with schedule: DisscussionSchedule, event: @escaping () -> Void) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 H시 m분에 예약됨"
        self.dateLabel.text = "\(formatter.string(from: schedule.date))"
        self.durationLabel.text = "\(schedule.duration)시간동안 진행"
        self.topicLabel.text = "주제: \(schedule.topic)"
        self.event = event
    }

}
