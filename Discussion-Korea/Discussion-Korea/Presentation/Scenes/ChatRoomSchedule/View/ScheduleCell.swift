//
//  ScheduleCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import UIKit

final class ScheduleCell: UITableViewCell {

    // MARK: properties

    private let topicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutViews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutViews()
    }

    // MARK: - methods

    func bind(_ viewModel: ScheduleItemViewModel) {
        self.topicLabel.text = viewModel.topicString
        self.dateLabel.text = viewModel.dateString
        self.durationLabel.text = viewModel.durationString
    }

    private func layoutViews() {
        let stackView = UIStackView(
            arrangedSubviews: [self.topicLabel,
                               self.dateLabel,
                               self.durationLabel]
        )
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
    }

}
