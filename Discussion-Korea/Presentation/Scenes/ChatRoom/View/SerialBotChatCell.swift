//
//  SerialBotChatCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/29.
//

import SnapKit
import UIKit

final class SerialBotChatCell: ChatCell {

    // MARK: properties

    private let contentLabel: UILabel = {
        let contentLabel = PaddingLabel()
        contentLabel.backgroundColor = .systemBackground
        contentLabel.textColor = .label
        contentLabel.font = UIFont.systemFont(ofSize: 15.0)
        contentLabel.layer.cornerRadius = 8
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byCharWrapping
        contentLabel.layer.masksToBounds = true
        return contentLabel
    }()

    private let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 10.0)
        return timeLabel
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutViews()
    }

    // MARK: - methods

    private func layoutViews() {
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(60)
            make.trailing.lessThanOrEqualToSuperview().offset(-80)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.timeLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(self.contentLabel.snp.trailing)
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(8)
            make.bottom.equalToSuperview()
        }
    }

    override func bind(_ viewModel: ChatItemViewModel) {
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = viewModel.textColor ?? .label
        self.contentLabel.backgroundColor = viewModel.backgroundColor ?? .systemBackground
        self.contentLabel.font = viewModel.contentFont
        self.timeLabel.text = viewModel.timeString
    }

}
