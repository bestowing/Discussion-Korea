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

    func setDefaultProfileImage() {
        self.image = UIImage(systemName: "person.fill")
    }

    func setDefaultChatRoomProfileImage() {
        self.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
    }

}
