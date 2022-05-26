//
//  UIImageView+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import UIKit
import Kingfisher

extension UIImageView {

    func setImage(_ url: URL) {
        self.kf.setImage(with: url)
    }

}
