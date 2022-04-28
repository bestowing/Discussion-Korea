//
//  UserListTableViewCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/27.
//

import UIKit

final class UserListTableViewCell: UITableViewCell {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!

    func bind(with userInfo: UserInfo) {
        if let description = userInfo.description {
            self.nicknameLabel.text = userInfo.nickname + " (\(description))"
        } else {
            self.nicknameLabel.text = userInfo.nickname
        }
    }

}
