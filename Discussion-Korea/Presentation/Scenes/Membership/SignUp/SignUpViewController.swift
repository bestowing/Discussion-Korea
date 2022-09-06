//
//  SignUpViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift

final class SignUpViewController: BaseViewController {

    // MARK: - properties

    var viewModel: SignUpViewModel!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .white
        indicator.backgroundColor = .gray
        indicator.layer.cornerRadius = 10.0
        return indicator
    }()

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let idField: FormField = {
        let textField = FormField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "이메일"
        textField.keyboardType = .emailAddress
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()

    private let passwordField: FormField = {
        let textField = FormField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "비밀번호"
        textField.isPassword = true
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()

    private let passwordCheckField: FormField = {
        let textField = FormField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "비밀번호 확인"
        textField.isPassword = true
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()

    private let nicknameField: FormField = {
        let textField = FormField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "닉네임"
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.red, for: .disabled)
        button.backgroundColor = UIColor.accentColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "회원가입"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton

        let logoImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "round_logo.png"))
            return imageView
        }()

        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.size.equalTo(50)
        }

        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = "방구석대한민국"
            label.font = UIFont.preferredBoldFont(forTextStyle: .body)
            label.textColor = .label
            return label
        }()
        self.view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }

        let stackView: UIStackView = {
            let stackView = UIStackView(
                arrangedSubviews: [
                    self.idField,
                    self.passwordField,
                    self.passwordCheckField,
                    self.nicknameField,
                    self.registerButton
                ]
            )
            stackView.axis = .vertical
            stackView.spacing = 5
            return stackView
        }()
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SignUpViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriverOnErrorJustComplete(),
            email: self.idField.rx.text.orEmpty.asDriver().skip(1),
            password: self.passwordField.rx.text.orEmpty.asDriver().skip(1),
            passwordCheck: self.passwordCheckField.rx.text.orEmpty.asDriver().skip(1),
            nickname: self.nicknameField.rx.text.orEmpty.asDriver().skip(1),
            register: self.registerButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.loading.drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        output.emailResult.drive(self.idField.rx.wrongMessage)
            .disposed(by: self.disposeBag)

        output.passwordResult.drive(self.passwordField.rx.wrongMessage)
            .disposed(by: self.disposeBag)

        output.passwordCheckResult.drive(self.passwordCheckField.rx.wrongMessage)
            .disposed(by: self.disposeBag)

        output.nicknameResult.drive(self.nicknameField.rx.wrongMessage)
            .disposed(by: self.disposeBag)

        output.registerEnabled.drive(self.registerButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
