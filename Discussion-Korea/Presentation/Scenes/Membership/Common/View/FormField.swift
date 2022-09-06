//
//  InputField.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift
import RxCocoa

final class FormField: UIView {

    // MARK: - properties

    var isPassword: Bool = false {
        willSet {
            self.textField.isSecureTextEntry = newValue
        }
    }

    var placeholder: String = "" {
        willSet {
            self.textField.placeholder = newValue
        }
    }

    var keyboardType: UIKeyboardType = .default {
        willSet {
            self.textField.keyboardType = newValue
        }
    }

    var borderStyle: UITextField.BorderStyle = .none {
        willSet {
            self.textField.borderStyle = newValue
        }
    }

    var font: UIFont? = UIFont.preferredFont(forTextStyle: .body) {
        willSet {
            self.textField.font = newValue
        }
    }

    fileprivate let textField: UITextField = {
        let textField = UITextField()
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    fileprivate let feedbackMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    fileprivate let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        return stackView
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
        self.stackView.addArrangedSubview(self.textField)
        self.stackView.addArrangedSubview(self.feedbackMessageLabel)
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension Reactive where Base: FormField {

    var text: ControlProperty<String?> {
        return base.textField.rx.text
    }

    var wrongMessage: Binder<FormResult?> {
        return Binder(self.base) { inputField, formResult in
            guard let formResult = formResult
            else {
                if inputField.stackView
                    .arrangedSubviews
                    .contains(inputField.feedbackMessageLabel) {
                    inputField.stackView
                        .removeArrangedSubview(inputField.feedbackMessageLabel)
                    inputField.feedbackMessageLabel
                        .removeFromSuperview()
                }
                return
            }
            if !inputField.stackView
                .arrangedSubviews
                .contains(inputField.feedbackMessageLabel) {
                inputField.stackView.addArrangedSubview(inputField.feedbackMessageLabel)
            }
            switch formResult {
            case .success:
                inputField.feedbackMessageLabel.text = ""
            case .failure(let reason):
                inputField.feedbackMessageLabel.text = reason
                inputField.feedbackMessageLabel.textColor = .red
            }
        }
    }

}
