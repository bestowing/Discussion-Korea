//
//  ProfileImageView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

import RxCocoa
import RxSwift
import UIKit

class CircleImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.layer.frame.height * 0.5
    }

}

final class ProfileImageView: CircleImageView {

    func setDefaultProfileImage() {
        self.image = UIImage(systemName: "person.fill")
    }

}

final class ChatRoomProfileImageView: CircleImageView {

    func setDefaultChatRoomProfileImage() {
        self.contentMode = .center
        self.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
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

extension Reactive where Base: ChatRoomProfileImageView {

    var url: Binder<URL?> {
        return Binder(self.base) { imageView, url in
            guard let url = url else {
                imageView.setDefaultChatRoomProfileImage()
                return
            }
            imageView.contentMode = .scaleAspectFill
            imageView.setImage(url)
        }
    }

}
