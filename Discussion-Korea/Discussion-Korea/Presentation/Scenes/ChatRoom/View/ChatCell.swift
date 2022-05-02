//
//  ChatCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import UIKit

class ChatCell: UICollectionViewCell {

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        self.layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

    func bind(_ viewModel: ChatItemViewModel) {
        fatalError("not implemented")
    }

}
