//
//  UserListTableViewCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/27.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!

    func bind(nickname: String) {
        self.nicknameLabel.text = nickname
    }

}
