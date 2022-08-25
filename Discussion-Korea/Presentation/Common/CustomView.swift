//
//  CustomView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

class CustomView: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }

    func setSubviews() {}

}
