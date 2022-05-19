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
        let imageView = UIImageView(image: UIImage(systemName: "message.fill"))
        imageView.tintColor = .primaryColor
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.numberOfLines = 1
        return label
    }()

    private let latestChatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let latestChatDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9.0)
        return label
    }()

    // TODO: 실시간으로 채팅방에 몇명 있는지 보여주는 Label이 있으면 좋을듯

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
        // FIXME: 채팅방 이름이 길때 생기는 문제 해결해야함
        self.contentView.addSubview(self.profileImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.latestChatLabel)
        self.contentView.addSubview(self.latestChatDateLabel)
        self.profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(45)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-30)
            make.top.equalTo(self.profileImageView.snp.top).offset(3)
        }
//        self.titleLabel.snp.contentHuggingHorizontalPriority = 252
        self.latestChatLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.leading)
//            make.trailing.lessThanOrEqualTo(self.latestChatDateLabel.snp.leading).offset(-5)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
        }
//        self.latestChatDateLabel.snp.contentHuggingHorizontalPriority = 752
//        self.latestChatDateLabel.snp.contentCompressionResistanceHorizontalPriority = 752
        self.latestChatDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
        }
    }

    func bind(_ viewModel: ChatRoomItemViewModel) {
        self.titleLabel.text = viewModel.title
        self.latestChatLabel.text = "테스트중이에요"
        self.latestChatDateLabel.text = "오후 3:52"
    }

}
