//
//  UserInfoPanel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit
import RxSwift

final class UserInfoPanel: UIView {

    // MARK: - properties

    var formatter: ((Int) -> String)?

    fileprivate let dayLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - init/deinit

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }

    private func setSubviews() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.7
        self.layer.borderColor = UIColor.systemGray3.cgColor
        self.addSubview(self.dayLabel)
        self.dayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }

}

extension Reactive where Base: UserInfoPanel {

    var day: Binder<Date> {
        return Binder(self.base) { userInfoPanel, date in
            let calendar = Calendar(identifier: .gregorian)
            let offsetComps = calendar.dateComponents([.day], from: date, to: Date())
            if case let (d?) = (offsetComps.day),
               let formatter = userInfoPanel.formatter {
                userInfoPanel.dayLabel.text =  formatter(d)
            }
        }
    }

}
