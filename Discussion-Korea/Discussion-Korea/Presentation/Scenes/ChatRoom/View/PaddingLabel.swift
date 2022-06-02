//
//  PaddingLabel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/03.
//

import UIKit

final class PaddingLabel: UILabel {

    // MARK: properties

    var padding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0) {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    // MARK: - init/deinit

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    // MARK: - methods

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: padding)
        let textRect = super.textRect(forBounds: insetRect,
                                      limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -padding.top,
                                          left: -padding.left,
                                          bottom: -padding.bottom,
                                          right: -padding.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.padding))
    }

}
