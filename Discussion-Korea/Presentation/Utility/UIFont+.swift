//
//  UIFont+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import UIKit

extension UIFont {

    static func preferredBoldFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        if let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: style)
            .withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: 0.0)
        }
        return UIFont.preferredFont(forTextStyle: style)
    }

}
