//
//  SelfChat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit

final class SelfChatCell: ChatCell {

    // MARK: - properties

    private let contentLabel: UILabel = {
        let contentLabel = PaddingLabel()
        contentLabel.backgroundColor = UIColor(named: "PrimaryColor")
        contentLabel.textColor = .white
        contentLabel.font = UIFont.systemFont(ofSize: 14.0)
        contentLabel.layer.cornerRadius = 8
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
        fatalError("not implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.timeLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentLabel.snp.bottom)
        }
    }

    // MARK: - methods

    override func bind(_ viewModel: ChatItemViewModel) {
        self.contentLabel.text = viewModel.chat.content
        self.timeLabel.text = viewModel.timeString
    }

}
