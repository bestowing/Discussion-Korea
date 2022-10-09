//
//  HomeMenuButton.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import RxSwift
import UIKit

final class HomeMenuButton: UIView {

    var isEnabled: Bool = true {
        willSet {
            self.titleLabel.textColor = newValue ? .label : .systemGray3
            self.imageView.tintColor = newValue ? .accentColor : .systemGray3
        }
    }

    let titleLabel: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.adjustsFontSizeToFitWidth = true
        title.adjustsFontForContentSizeCategory = true
        title.textColor = .label
        return title
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

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
        self.layer.borderWidth = 0.7
        self.layer.borderColor = UIColor.systemGray3.cgColor
        self.addSubview(self.titleLabel)
        self.addSubview(self.imageView)
        self.titleLabel.snp.contentHuggingVerticalPriority = 999
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }
        self.imageView.snp.contentHuggingVerticalPriority = 1
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.width.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }

}
