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

    // MARK: properties

    fileprivate let messageTextView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.font = UIFont.systemFont(ofSize: 14.0)
        messageTextView.isScrollEnabled = false
        messageTextView.layer.borderColor = UIColor.systemGray5.cgColor
        messageTextView.layer.borderWidth = 1.0
        messageTextView.backgroundColor = .systemGray6
        messageTextView.layer.cornerRadius = 15.0
        messageTextView.layer.masksToBounds = true
        messageTextView.accessibilityLabel = "채팅 내용"
        messageTextView.accessibilityHint = "채팅할 내용 입력"
        return messageTextView
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
        self.addSubview(self.messageTextView)
        self.addSubview(self.sendButton)
        self.messageTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        self.sendButton.snp.makeConstraints { make in
            make.leading.equalTo(self.messageTextView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(self.messageTextView)
            make.size.equalTo(26)
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

}
