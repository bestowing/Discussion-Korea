//
//  NoticeView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/23.
//

import UIKit
import RxSwift

final class NoticeView: UIView {

    // MARK: properties

    fileprivate let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "megaphone.fill"))
        imageView.tintColor = UIColor.label
        return imageView
    }()

    fileprivate let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    fileprivate let remainTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
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
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.systemBackground
        self.addSubview(self.iconImageView)
        self.addSubview(self.contentLabel)
        self.addSubview(self.remainTimeLabel)
        self.iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(10)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
            make.size.equalTo(30)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(10)
            make.top.equalTo(self.iconImageView)
            make.trailing.equalToSuperview()
        }
        self.remainTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(self.contentLabel)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

}

extension Reactive where Base: NoticeView {

    var content: Binder<String> {
        return Binder(self.base) { noticeView, content in
            noticeView.isHidden = content.isEmpty
            noticeView.contentLabel.text = content
        }
    }

    var remainTime: Binder<String> {
        return Binder(self.base) { noticeView, timeString in
            noticeView.remainTimeLabel.text = timeString
        }
    }

}
