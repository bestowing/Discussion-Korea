//
//  ScheduleCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import UIKit

final class ScheduleCell: UITableViewCell {

    // MARK: - properties

    private let topicLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
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

    private func layoutViews() {
        self.selectionStyle = .none
        let stackView = UIStackView(
            arrangedSubviews: [self.topicLabel,
                               self.dateLabel]
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

    // MARK: - methods

    func bind(_ viewModel: ScheduleItemViewModel) {
        self.topicLabel.text = viewModel.topicString
        self.dateLabel.text = viewModel.dateString
    }

}
