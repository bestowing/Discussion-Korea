//
//  NoticeView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/20.
//

import SnapKit
import UIKit
import RxSwift

final class LiveChatView: UIView {

    // MARK: properties

    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()

    fileprivate let label: UILabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(
            top: 12.0, left: 20.0, bottom: 12.0, right: 20.0)
        )
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingHead
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
        self.backgroundColor = .systemBackground
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.label)
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        self.label.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom)
        }
    }

}

extension Reactive where Base: LiveChatView {

    var chatViewModel: Binder<ChatItemViewModel> {
        return Binder(self.base) { liveChatView, viewModel in
            liveChatView.isHidden = viewModel.content.isEmpty
            liveChatView.descriptionLabel.text = "\(viewModel.nickname)님이 작성중입니다..."
            liveChatView.label.text = viewModel.content
            liveChatView.backgroundColor = viewModel.backgroundColor
        }
    }

}
