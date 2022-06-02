//
//  OtherChat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import SnapKit
import UIKit

final class OtherChatCell: ChatCell {

    // MARK: properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .primaryColor
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
        self.contentView.addSubview(self.profileImageView)
        self.contentView.addSubview(self.nicknameLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.timeLabel)
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(8)
        }
        self.nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
            make.top.equalTo(self.profileImageView.snp.top).offset(2)
        }
        self.nicknameLabel.snp.contentHuggingVerticalPriority = 252
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.nicknameLabel.snp.leading)
            make.trailing.lessThanOrEqualToSuperview().offset(-80)
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        self.contentLabel.snp.contentHuggingHorizontalPriority = 252
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(8)
            make.bottom.equalTo(self.contentLabel.snp.bottom)
        }
        self.timeLabel.snp.contentCompressionResistanceHorizontalPriority = 751
    }

    override func bind(_ viewModel: ChatItemViewModel) {
        if let image = viewModel.image {
            self.profileImageView.image = image
        } else if let url = viewModel.url {
            self.profileImageView.setImage(url)
        }
        self.nicknameLabel.text = viewModel.nickname + viewModel.sideString
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = viewModel.textColor ?? .label
        self.contentLabel.backgroundColor = viewModel.backgroundColor ?? .systemBackground
        self.contentLabel.font = viewModel.contentFont
        self.timeLabel.text = viewModel.timeString
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
    }

}
