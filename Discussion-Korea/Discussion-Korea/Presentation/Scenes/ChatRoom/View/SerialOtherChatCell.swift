//
//  SerialOtherChatCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import SnapKit
import UIKit

final class SerialOtherChatCell: ChatCell {

    // MARK: properties

    private let contentLabel: UILabel = {
        let contentLabel = PaddingLabel()
        contentLabel.backgroundColor = .systemBackground
        contentLabel.textColor = .label
        contentLabel.font = UIFont.systemFont(ofSize: 15.0)
        contentLabel.layer.cornerRadius = 8
        contentLabel.layer.masksToBounds = true
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byCharWrapping
        return contentLabel
    }()

    private let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 10.0)
        return timeLabel
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(55)
            make.trailing.lessThanOrEqualToSuperview().offset(-80)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.contentLabel.snp.contentHuggingHorizontalPriority = 252
        self.timeLabel.snp.contentCompressionResistanceHorizontalPriority = 751
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(8)
            make.bottom.equalTo(self.contentLabel.snp.bottom)
        }
    }

    // MARK: - methods

    override func bind(_ viewModel: ChatItemViewModel) {
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = viewModel.textColor ?? .label
        self.contentLabel.backgroundColor = viewModel.backgroundColor ?? .systemBackground
        self.contentLabel.font = viewModel.contentFont
        self.timeLabel.text = viewModel.timeString
    }

}
