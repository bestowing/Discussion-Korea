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

    fileprivate let chartView: UILabel = {
        let label = UILabel()
        return label
    }()

    fileprivate let agreeView: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .left
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.agreeColor
        return label
    }()

    fileprivate let disagreeView: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .right
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.disagreeColor
        return label
    }()

    fileprivate let sideControl: UISegmentedControl = {
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
        self.addSubview(self.chartView)
        self.addSubview(self.agreeView)
        self.addSubview(self.disagreeView)
        self.addSubview(self.sideControl)
        self.supportLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        self.chartView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        self.agreeView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(self.supportLabel.snp.bottom).offset(10)
            make.width.equalTo(self.chartView.snp.width).multipliedBy(0.5).priority(.medium)
            make.width.greaterThanOrEqualTo(30).priority(.high)
            make.height.equalTo(50)
        }
        self.disagreeView.snp.makeConstraints { make in
            make.leading.equalTo(self.agreeView.snp.trailing).priority(.medium)
            make.trailing.equalToSuperview()
            make.top.equalTo(self.agreeView.snp.top)
            make.width.greaterThanOrEqualTo(30).priority(.high)
            make.height.equalTo(self.agreeView.snp.height)
        }
        self.sideControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.agreeView.snp.bottom).offset(10)
        }
    }

}

extension Reactive where Base: OpinionView {

    var value: ControlProperty<Int> {
        return base.sideControl.rx.value
    }

    var canParticipate: Binder<Bool> {
        return Binder(self.base) { opinionView, canParticipate in
            opinionView.sideControl.isEnabled = canParticipate
        }
    }

    var agree: Binder<UInt> {
        return Binder(self.base) { opinionView, agree in
            opinionView.agreeView.text = String(agree)
        }
    }

    var disagree: Binder<UInt> {
        return Binder(self.base) { opinionView, disagree in
            opinionView.disagreeView.text = String(disagree)
        }
    }

    var ratio: Binder<Double> {
        return Binder(self.base) { opinionView, ratio in
            opinionView.agreeView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalTo(opinionView.supportLabel.snp.bottom).offset(10)
                make.width.equalTo(opinionView.chartView.snp.width).multipliedBy(ratio).priority(.medium)
                make.width.greaterThanOrEqualTo(30).priority(.high)
                make.height.equalTo(50)
            }
            UIView.animate(withDuration: 0.3) {
                opinionView.layoutIfNeeded()
            }
        }
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
