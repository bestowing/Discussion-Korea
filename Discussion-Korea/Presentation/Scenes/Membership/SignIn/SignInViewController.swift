//
//  SignInViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift

final class SignInViewController: BaseViewController {

    // MARK: - properties

    var viewModel: SignInViewModel!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .white
        indicator.backgroundColor = .gray
        indicator.layer.cornerRadius = 10.0
        return indicator
    }()

    private let idField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "이메일"
        textField.keyboardType = .emailAddress
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "비밀번호"
        textField.isSecureTextEntry = true
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.accentColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = UIColor.clear
        return button
    }()

    private let resetPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("비밀번호 재설정", for: .normal)
        button.setTitleColor(UIColor.secondaryLabel, for: .normal)
        button.backgroundColor = UIColor.clear
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center

        let logoImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: "round_logo.png"))
            return imageView
        }()
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.size.equalTo(70)
        }

        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.text = "신개념 토론 플랫폼"
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            return label
        }()
        self.view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(15)
        }

        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "방구석대한민국"
            label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
            label.textColor = .label
            label.textAlignment = .center
            return label
        }()
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(15)
        }

        let stackView: UIStackView = {
            let stackView = UIStackView(
                arrangedSubviews: [
                    self.idField, self.passwordField, self.loginButton
                ]
            )
            stackView.axis = .vertical
            stackView.spacing = 5
            return stackView
        }()

        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }

        self.view.addSubview(self.signUpButton)
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
        self.view.addSubview(self.resetPasswordButton)
        self.resetPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(self.signUpButton.snp.bottom).offset(5)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SignInViewModel.Input(
            email: self.idField.rx.text.orEmpty.asDriver(),
            password: self.passwordField.rx.text.orEmpty.asDriver(),
            signInTrigger: self.loginButton.rx.tap.asDriver(),
            signUpTrigger: self.signUpButton.rx.tap
                .asDriverOnErrorJustComplete(),
            resetPasswordTrigger: self.resetPasswordButton.rx.tap
                .asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.loading.drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
