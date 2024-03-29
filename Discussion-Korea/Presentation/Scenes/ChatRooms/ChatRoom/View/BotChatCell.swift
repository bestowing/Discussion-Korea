//
//  BotChatCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/29.
//

import SnapKit
import UIKit

final class BotChatCell: ChatCell {

    // MARK: - properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
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

        let stackView = UIStackView(
            arrangedSubviews: [self.profileImageView, self.nicknameLabel]
        )
        stackView.axis = .vertical
        stackView.spacing = 10
        self.contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(7)
        }
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
        self.contentLabel.font = viewModel.contentFont
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
    }

}
