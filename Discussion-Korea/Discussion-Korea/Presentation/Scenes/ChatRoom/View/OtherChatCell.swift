//
//  OtherChat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import SnapKit
import UIKit

final class OtherChatCell: ChatCell {

    // MARK: - properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = UIColor(named: "PrimaryColor")
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.systemFont(ofSize: 12.0)
        return nicknameLabel
    }()

    private let contentLabel: UILabel = {
        let contentLabel = PaddingLabel()
        contentLabel.backgroundColor = .systemBackground
        contentLabel.textColor = .label
        contentLabel.font = UIFont.systemFont(ofSize: 14.0)
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
        self.contentView.addSubview(self.profileImageView)
        self.contentView.addSubview(self.nicknameLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        self.profileImageView.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(41)
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(8)
        }
        self.nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
            make.top.equalTo(self.profileImageView.snp.top).offset(2)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.nicknameLabel.snp.leading)
            make.trailing.lessThanOrEqualToSuperview().offset(-80)
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        self.nicknameLabel.snp.contentHuggingVerticalPriority = 252
        self.contentLabel.snp.contentHuggingHorizontalPriority = 252
        self.timeLabel.snp.contentCompressionResistanceHorizontalPriority = 751
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(8)
            make.bottom.equalTo(self.contentLabel.snp.bottom)
        }
    }

    // MARK: - methods

    override func bind(_ viewModel: ChatItemViewModel) {
        self.profileImageView.image = UIImage(systemName: "person.fill")
        self.nicknameLabel.text = viewModel.chat.nickName
        self.contentLabel.text = viewModel.chat.content
        self.timeLabel.text = viewModel.timeString
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
    }

}
