//
//  ResizableLabel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/15.
//

import UIKit

final class ResizableLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureResizable()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureResizable()
    }

    private func configureResizable() {
        self.adjustsFontForContentSizeCategory = true
    }

}
