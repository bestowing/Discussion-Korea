//
//  ProfileImageView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

import RxCocoa
import RxSwift
import UIKit

final class ProfileImageView: UIImageView {

    func setDefaultProfileImage() {
        self.image = UIImage(systemName: "person.fill")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.layer.frame.height * 0.5
    }

}

extension Reactive where Base: ProfileImageView {

    var url: Binder<URL?> {
        return Binder(self.base) { imageView, url in
            guard let url = url else {
                imageView.setDefaultProfileImage()
                return
            }
            imageView.setImage(url)
        }
    }

}
