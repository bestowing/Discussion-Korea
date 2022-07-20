//
//  ChatPreview.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/11.
//

import UIKit

final class ChatPreview: UIView {

    // MARK: properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()

    private let downButton: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = .systemGray
        return imageView
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
        self.backgroundColor = UIColor.systemBackground
        self.layer.cornerRadius = 8
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.masksToBounds = true
        self.addSubview(self.profileImageView)
        self.addSubview(self.nicknameLabel)
        self.addSubview(self.contentLabel)
        self.addSubview(self.downButton)
        self.profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(25)
        }
        self.nicknameLabel.snp.contentHuggingHorizontalPriority = 755
        self.nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(5)
            make.centerY.equalTo(self.profileImageView.snp.centerY)
        }
        self.contentLabel.snp.contentHuggingHorizontalPriority = 200
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.nicknameLabel.snp.trailing).offset(5)
            make.centerY.equalTo(self.profileImageView.snp.centerY)
        }
        self.downButton.snp.contentHuggingHorizontalPriority = 755
        self.downButton.snp.makeConstraints { make in
            make.leading.equalTo(self.contentLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalTo(self.profileImageView.snp.centerY)
            make.size.equalTo(15)
        }
    }

    // MARK: - methods

    func bind(_ viewModel: ChatItemViewModel) {
        self.isHidden = false
        if let image = viewModel.image {
            self.profileImageView.image = image
        } else if let url = viewModel.url {
            self.profileImageView.setImage(url)
        }
        self.nicknameLabel.text = viewModel.nickname + viewModel.sideString
        self.contentLabel.text = viewModel.content
    }

}
