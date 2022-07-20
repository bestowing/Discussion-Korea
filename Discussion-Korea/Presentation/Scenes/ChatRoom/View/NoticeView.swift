//
//  NoticeView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/20.
//

import SnapKit
import UIKit

final class NoticeView: UIView {

    // MARK: properties

    private let label: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(
            top: 8.0, left: 20.0, bottom: 8.0, right: 20.0)
        )
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .label
        label.backgroundColor = UIColor.systemBackground
//        label.layer.cornerRadius = 4
        label.layer.shadowOpacity = 0.15
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.masksToBounds = false
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
        self.isHidden = true
        self.addSubview(self.label)
        self.label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - methods

    func bind(with notice: String) {
        self.isHidden = notice.isEmpty
        self.label.text = notice
    }

}
