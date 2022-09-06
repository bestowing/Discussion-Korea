//
//  InputField.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift
import RxCocoa

final class InputField: UIView {

    // MARK: - properties

    var placeHolder: String = "" {
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

    fileprivate let wrongMessageLabel: UILabel = {
        let label = UILabel()
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
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

}

extension Reactive where Base: InputField {

    var text: ControlProperty<String?> {
        return base.textField.rx.text
    }

    var wrongMessage: Binder<String?> {
        return Binder(self.base) { inputField, message in
            guard let message = message
            else {
//                inputField.stackView.removeArrangedSubview(<#T##view: UIView##UIView#>)
                return
            }
        }
    }

}
