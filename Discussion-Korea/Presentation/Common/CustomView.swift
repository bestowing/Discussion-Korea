//
//  CustomView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

/// Custom View에서 반복되는 코드를 줄이기 위한 클래스
class CustomView: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }

    /// init을 매번 작성할 필요 없이 이 메서드만 오버라이딩해도 되게 만들었음
    func setSubviews() {}

}
