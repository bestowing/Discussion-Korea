//
//  SerialMessageCollectionViewCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/23.
//

import UIKit
import Domain

final class SerialMessageCollectionViewCell: UICollectionViewCell {

    // MARK: properties

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    // MARK: methods

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

}

extension SerialMessageCollectionViewCell: MessageCell {

    static func dequeueReusableCell(from collectionView: UICollectionView, for indexPath: IndexPath) -> MessageCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: Self.identifier, for: indexPath) as? MessageCell ?? MessageCollectionViewCell()
    }

    func bind(_ viewModel: ChatItemViewModel) {
        self.contentLabel.text = viewModel.chat.content
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        if let date = viewModel.chat.date {
            self.timeLabel.text = dateFormatter.string(from: date)
        } else {
            self.timeLabel.text = ""
        }
    }

}
