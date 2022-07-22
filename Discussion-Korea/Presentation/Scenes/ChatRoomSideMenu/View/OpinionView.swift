//
//  OpinionView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/21.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

final class OpinionView: UIView {

    // MARK: properties

    fileprivate let supportLabel: UILabel = {
        let label = UILabel()
        label.text = "여론조사"
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()

    fileprivate var sideControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            "찬성", "반대", "기타"
        ])
        return control
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
        self.addSubview(self.supportLabel)
        self.addSubview(self.sideControl)
        self.supportLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        self.sideControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.supportLabel.snp.bottom).offset(10)
        }
    }

}

extension Reactive where Base: OpinionView {

    var value: ControlProperty<Int> {
        return base.sideControl.rx.value
    }

    var side: Binder<Side?> {
        return Binder(self.base) { opinionView, side in
            guard let side = side else { return }
            let indexes = [Side.agree, Side.disagree, Side.judge]
            guard let index = indexes.firstIndex(of: side)
            else { return }
            opinionView.sideControl.selectedSegmentIndex = index
            
        }
    }

}
