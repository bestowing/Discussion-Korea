//
//  OtherChat.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import SnapKit
import UIKit

class OtherChatCell: ChatCell {

    // MARK: - properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        return nicknameLabel
    }()

    private let contentLabel: UILabel = {
        let contentLabel = PaddingLabel()
        contentLabel.backgroundColor = .systemBackground
        contentLabel.textColor = .label
        contentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentLabel.layer.cornerRadius = 8
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byCharWrapping
        contentLabel.layer.masksToBounds = true
        return contentLabel
    }()

    fileprivate let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 14.0)
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
            make.top.equalToSuperview().offset(10)
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
            make.bottom.equalToSuperview().inset(7)
        }
        self.contentLabel.snp.contentHuggingHorizontalPriority = 252
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(8)
            make.bottom.equalTo(self.contentLabel.snp.bottom)
        }
        self.timeLabel.snp.contentCompressionResistanceHorizontalPriority = 751

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapProfile))
        self.profileImageView.addGestureRecognizer(tapGesture)
    }

    override func bind(_ viewModel: ChatItemViewModel) {
        if let image = viewModel.image {
            self.profileImageView.image = image
        } else if let url = viewModel.url {
            self.profileImageView.setImage(url)
        }
        self.nicknameLabel.text = viewModel.nickname + viewModel.sideString
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = super.textColor(viewModel)
        self.contentLabel.backgroundColor = viewModel.backgroundColor ?? .systemBackground
        self.contentLabel.font = viewModel.contentFont
        self.timeLabel.text = viewModel.timeString
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
    }

    @objc private func tapProfile() {
        super.action?.performAction()
    }

}

final class WritingChatCell: OtherChatCell {

    override func bind(_ viewModel: ChatItemViewModel) {
        super.bind(viewModel)
        self.timeLabel.text = "작성중..."
    }

}
