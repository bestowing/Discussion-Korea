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

    fileprivate let resultLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let versusLabel: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        label.text = "VS"
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        label.backgroundColor = .systemBackground
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    fileprivate let chartView: UILabel = {
        let label = UILabel()
        return label
    }()

    fileprivate let agreeView: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 13.0, weight: .bold)
        label.textAlignment = .left
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.agreeColor
        return label
    }()

    fileprivate let disagreeView: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 13.0, weight: .bold)
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
        self.addSubview(self.resultLabel)
        self.addSubview(self.chartView)
        self.addSubview(self.agreeView)
        self.addSubview(self.disagreeView)
        self.addSubview(self.versusLabel)
        self.addSubview(self.sideControl)
        self.supportLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        self.resultLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.supportLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.supportLabel)
        }
        self.chartView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        self.versusLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.chartView)
            make.centerY.equalTo(self.agreeView)
        }
        self.agreeView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(self.supportLabel.snp.bottom).offset(10)
            make.width.equalTo(self.chartView.snp.width).multipliedBy(0.48)
//            make.width.greaterThanOrEqualTo(30).priority(.high)
            make.height.equalTo(50)
        }
        self.disagreeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(self.agreeView.snp.top)
            make.width.equalTo(self.chartView.snp.width).multipliedBy(0.48)
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

    var side: Binder<Side?> {
        return Binder(self.base) { opinionView, side in
            guard let side = side else { return }
            let indexes = [Side.agree, Side.disagree, Side.judge]
            guard let index = indexes.firstIndex(of: side)
            else { return }
            opinionView.sideControl.selectedSegmentIndex = index
        }
    }

    var agreeAndDisagree: Binder<(UInt, UInt)> {
        return Binder(self.base) { opinionView, result in
            let agree = result.0
            let disagree = result.1
            opinionView.agreeView.text = (agree < disagree ? "" : "🔥") + String(agree)
            opinionView.agreeView.textColor = agree > disagree ? .accentColor : .label
            opinionView.disagreeView.text = String(disagree) + (agree > disagree ? "" : "🔥")
            opinionView.disagreeView.textColor = disagree > agree ? .accentColor : .label
            opinionView.resultLabel.text = disagree == agree ? "무승부!" : agree > disagree ? "찬성측 우세!" : "반대측 우세!"
        }
    }

}
