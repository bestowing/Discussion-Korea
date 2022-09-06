//
//  ChatInputView.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/24.
//

import UIKit
import RxCocoa
import RxSwift

final class ChatInputView: UIView {

    // MARK: - properties

    fileprivate let messageTextView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        messageTextView.backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.accessibilityLabel = "채팅 내용"
        messageTextView.accessibilityHint = "채팅할 내용 입력"
        return messageTextView
    }()

    fileprivate let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()

    fileprivate let sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.setBackgroundImage(UIImage(systemName: "paperplane"), for: .disabled)
        sendButton.tintColor = UIColor.accentColor
        sendButton.isEnabled = false
        sendButton.accessibilityLabel = "채팅 보내기"
        return sendButton
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
        self.backgroundColor = .systemBackground
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray6
        backgroundView.layer.borderColor = UIColor.systemGray5.cgColor
        backgroundView.layer.borderWidth = 1.0
        backgroundView.layer.cornerRadius = 15.0
        backgroundView.layer.masksToBounds = true
        self.addSubview(backgroundView)
        self.addSubview(self.messageTextView)
        self.addSubview(self.timeLabel)
        self.addSubview(self.sendButton)
        backgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        self.messageTextView.snp.contentHuggingHorizontalPriority = 1
        self.messageTextView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundView).offset(5)
            make.top.equalTo(backgroundView).offset(5)
            make.bottom.equalTo(backgroundView).offset(-5)
        }
        self.timeLabel.snp.contentHuggingHorizontalPriority = 999
        self.timeLabel.snp.contentCompressionResistanceHorizontalPriority = 999
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.messageTextView.snp.trailing).offset(10)
            make.trailing.equalTo(backgroundView).offset(-10)
            make.centerY.equalTo(backgroundView)
        }
        self.sendButton.snp.makeConstraints { make in
            make.leading.equalTo(backgroundView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(backgroundView)
            make.size.equalTo(backgroundView.snp.width).multipliedBy(0.1)
        }
    }

}

extension Reactive where Base: ChatInputView {

    var send: ControlEvent<Void> {
        return base.sendButton.rx.tap
    }

    var chatContent: ControlProperty<String> {
        return base.messageTextView.rx.text.orEmpty
    }

    var sendEnable: Binder<Bool> {
        return Binder(self.base) { chatInputView, enable in
            chatInputView.sendButton.isEnabled = enable
        }
    }

    var isEditable: Binder<Bool> {
        return Binder(self.base) { chatInputView, editable in
            chatInputView.messageTextView.isEditable = editable
        }
    }

    var sendEvent: Binder<Void> {
        return Binder(self.base) { chatInputView, _ in
            chatInputView.messageTextView.text = ""
        }
    }

    var remainTime: Binder<String> {
        return Binder(self.base) { chatInputView, timeString in
            chatInputView.timeLabel.text = timeString
        }
    }

}
