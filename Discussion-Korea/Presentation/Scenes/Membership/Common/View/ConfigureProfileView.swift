//
//  ConfigureProfileView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/07.
//

import UIKit
import RxCocoa
import RxGesture
import RxSwift

final class ConfigureProfileView: UIView {

    // MARK: - properties

    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDefaultProfileImage()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .accentColor
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let profileBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.circle.fill")
        imageView.tintColor = .label
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemBackground
        return imageView
    }()

    fileprivate let nicknameField: FormField = {
        let textField = FormField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "닉네임"
        return textField
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
        self.addSubview(self.profileImageView)
        self.addSubview(self.profileBadge)
        self.addSubview(self.nicknameField)
        self.profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(self.profileImageView.snp.width)
        }
        self.profileBadge.snp.makeConstraints { make in
            make.trailing.equalTo(self.profileImageView)
            make.bottom.equalTo(self.profileImageView)
            make.size.equalTo(40)
        }
        self.nicknameField.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
    }
}

extension Reactive where Base: ConfigureProfileView {

    var nickname: ControlProperty<String?> {
        return base.nicknameField.rx.text
    }

    var url: Binder<URL> {
        return base.profileImageView.rx.url
    }

    var tapImage: Observable<Void> {
        return base.profileImageView.rx
            .tapGesture()
            .when(.recognized)
            .mapToVoid()
    }

}
