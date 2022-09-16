//
//  UIImageView+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Kingfisher
import RxSwift
import UIKit

extension UIImageView {

    func setImage(_ url: URL) {
        self.kf.setImage(with: url)
    }

}

extension Reactive where Base: UIImageView {

    var url: Binder<URL?> {
        return Binder(self.base) { imageView, url in
            guard let url = url else { return }
            imageView.setImage(url)
        }
    }

}
