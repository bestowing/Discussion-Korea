//
//  SelfChat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit

final class SelfChatCell: ChatCell {

    // MARK: properties

    private let contentLabel: UILabel = {
        let contentLabel = ResizableLabel()
        contentLabel.textColor = .white
        contentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byCharWrapping
        return contentLabel
    }()

    private let timeLabel: UILabel = {
        let timeLabel = ResizableLabel()
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        return timeLabel
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }

    private func setSubviews() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.accentColor
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.masksToBounds = true
        self.contentView.addSubview(backgroundView)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        backgroundView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(80)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(backgroundView).offset(8)
            make.bottom.trailing.equalTo(backgroundView).inset(8)
        }
        self.timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(backgroundView.snp.leading).offset(-8)
            make.bottom.equalTo(backgroundView.snp.bottom)
        }
    }

    // MARK: - methods

    override func bind(_ viewModel: ChatItemViewModel) {
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = viewModel.textColor ?? .label
        self.contentLabel.backgroundColor = viewModel.backgroundColor ?? .accentColor
        self.contentLabel.font = viewModel.contentFont
        self.timeLabel.text = viewModel.timeString
    }

}
