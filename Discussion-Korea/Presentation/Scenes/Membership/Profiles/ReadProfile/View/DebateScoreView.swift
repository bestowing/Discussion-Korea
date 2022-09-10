//
//  DebateScoreView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import SnapKit
import UIKit
import RxSwift

final class DebateScoreView: UIView {

    // MARK: - properties

    fileprivate let winLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    fileprivate let drawLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    fileprivate let loseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title1)
        label.numberOfLines = 0
        label.textAlignment = .center
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
        let titleLabel = UILabel()
        titleLabel.text = "토론 전적"
        titleLabel.font = UIFont.preferredBoldFont(forTextStyle: .body)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        let stackView = UIStackView(arrangedSubviews: [
            {
                let stackView = UIStackView(arrangedSubviews: [
                    self.winLabel, self.drawLabel, self.loseLabel
                ])
                stackView.distribution = .fillEqually
                return stackView
            }(),
            {
                let stackView = UIStackView(arrangedSubviews: [
                    {
                        let label = UILabel()
                        label.text = "승"
                        label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.textAlignment = .center
                        return label
                    }(),
                    {
                        let label = UILabel()
                        label.text = "무"
                        label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.textAlignment = .center
                        return label
                    }(),
                    {
                        let label = UILabel()
                        label.text = "패"
                        label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.textAlignment = .center
                        return label
                    }()
                ])
                stackView.distribution = .fillEqually
                return stackView
            }()
        ])
        stackView.axis = .vertical
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}

extension Reactive where Base: DebateScoreView {

    var score: Binder<(win: Int, draw: Int, lose: Int)> {
        return Binder(self.base) { debateScoreView, score in
            debateScoreView.winLabel.text = score.win.numberFormatter()
            debateScoreView.drawLabel.text = score.draw.numberFormatter()
            debateScoreView.loseLabel.text = score.lose.numberFormatter()
        }
    }

}
