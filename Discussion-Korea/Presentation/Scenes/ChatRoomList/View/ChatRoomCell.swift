//
//  ChatRoomCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit

final class ChatRoomCell: UICollectionViewCell {

    // MARK: properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .accentColor
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.boldSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize
        )
        label.numberOfLines = 1
        return label
    }()

    private let numberOfUsersLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize,
            weight: .light
        )
        return label
    }()

    private let latestChatLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 1
        label.textColor = .systemGray
        return label
    }()

    private let latestChatDateLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .systemGray
        return label
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
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.numberOfUsersLabel)
        self.contentView.addSubview(self.latestChatLabel)
        self.contentView.addSubview(self.latestChatDateLabel)
        self.profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
            make.size.equalTo(50)
        }
        self.titleLabel.snp.contentCompressionResistanceHorizontalPriority = 1
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(12)
            make.top.equalTo(self.profileImageView.snp.top).offset(3)
        }
        self.numberOfUsersLabel.snp.contentCompressionResistanceHorizontalPriority = 999
        self.numberOfUsersLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.centerY.equalTo(self.titleLabel)
        }
        self.latestChatLabel.snp.contentHuggingHorizontalPriority = 1
        self.latestChatLabel.snp.contentCompressionResistanceHorizontalPriority = 1
        self.latestChatLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        self.latestChatDateLabel.snp.contentHuggingHorizontalPriority = 999
        self.latestChatDateLabel.snp.contentCompressionResistanceHorizontalPriority = 999
        self.latestChatDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.latestChatLabel.snp.trailing)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(self.latestChatLabel)
        }
    }

    func bind(_ viewModel: ChatRoomItemViewModel) {
        if let url = viewModel.chatRoom.profileURL {
            self.profileImageView.setImage(url)
        } else {
            self.profileImageView.setDefaultChatRoomProfileImage()
        }
        self.titleLabel.text = viewModel.title
        self.latestChatLabel.text = viewModel.latestChatContent
        self.latestChatDateLabel.text = viewModel.latestChatDate
        self.numberOfUsersLabel.text = viewModel.numbersOfUser
    }

}
