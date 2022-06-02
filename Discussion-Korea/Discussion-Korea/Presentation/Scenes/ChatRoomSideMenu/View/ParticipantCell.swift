//
//  ParticipantCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import SnapKit
import UIKit

final class ParticipantCell: UITableViewCell {

    // MARK: properties

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.primaryColor
        imageView.tintColor = .white
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.0)
        return label
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutViews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutViews()
    }

    // MARK: - methods

    private func layoutViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.profileImageView)
        self.contentView.addSubview(self.nicknameLabel)
        self.profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3)
            make.width.equalTo(38)
            make.height.equalTo(41)
        }
        self.nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.profileImageView)
        }
    }

    func bind(_ viewModel: ParticipantItemViewModel) {
        if let url = viewModel.userInfo.profileURL {
            self.profileImageView.setImage(url)
        } else {
            self.profileImageView.image = UIImage(systemName: "person.fill")
        }
        self.nicknameLabel.text = viewModel.nickname
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil
    }

}
