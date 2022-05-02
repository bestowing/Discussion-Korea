//
//  PaddingLabel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import UIKit

final class PaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.padding))
    }
}
