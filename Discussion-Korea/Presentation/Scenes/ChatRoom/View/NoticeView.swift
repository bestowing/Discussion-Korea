//
//  NoticeView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/20.
//

import SnapKit
import UIKit

final class NoticeView: UIView {

    // MARK: properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()

    private let label: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(
            top: 12.0, left: 20.0, bottom: 12.0, right: 20.0)
        )
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingHead
        label.layer.shadowOpacity = 0.15
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.masksToBounds = false
        return label
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
        self.isHidden = true
        self.backgroundColor = .systemBackground
        self.addSubview(self.profileImageView)
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.label)
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.profileImageView.snp.bottom).offset(10)
        }
        self.label.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom)
        }
    }

    // MARK: - methods

    func bind(with viewModel: ChatItemViewModel) {
        self.isHidden = viewModel.content.isEmpty
        if let image = viewModel.image {
            self.profileImageView.image = image
        } else if let url = viewModel.url {
            self.profileImageView.setImage(url)
        }
        self.descriptionLabel.text = "\(viewModel.nickname)님이 작성중입니다..."
        self.label.text = viewModel.content
        self.backgroundColor = viewModel.backgroundColor
    }

}
