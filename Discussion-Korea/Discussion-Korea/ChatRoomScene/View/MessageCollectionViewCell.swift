//
//  MessageCollectionViewCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/18.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {

    // MARK: properties

    static let identifier = "MessageCollectionViewCell"

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    // MARK: methods

    func bind(message: Message) {
        self.nicknameLabel.text = message.userID
        self.contentLabel.text = message.content
        self.timeLabel.text = "오후 7:33"
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

}