//
//  ChatCell.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import UIKit

class ChatCell: UICollectionViewCell {

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        print("preferredLayoutAttributesFitting")
//        super.preferredLayoutAttributesFitting(layoutAttributes)
//        self.layoutIfNeeded()
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        print(frame.size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
    }

    func bind(_ viewModel: ChatItemViewModel) {
        fatalError("not implemented")
    }

    func getAccessibilityLabel(_ viewModel: ChatItemViewModel) -> String {
        var label = ""
        if let toxic = viewModel.chat.toxic,
           toxic {
            label += "방장봇에 의해 가려진 채팅을"
        } else {
            label += "\(viewModel.chat.content)라고"
        }
        if let side = viewModel.chat.side,
           side == .agree || side == .disagree {
            label += " \(side == .agree ? "찬성" : "반대")측의"
        }
        label += " \(viewModel.nickname)님이"
        if let date = viewModel.chat.date {
            let dateString = self.humanFriendlyDateString(from: date)
            label += "\(dateString)에 "
        }
        return label + " 채팅을 보냈어요."
    }

}

fileprivate extension ChatCell {

    func humanFriendlyDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h시 m분"
        dateFormatter.locale = Locale(identifier: "ko")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

}
