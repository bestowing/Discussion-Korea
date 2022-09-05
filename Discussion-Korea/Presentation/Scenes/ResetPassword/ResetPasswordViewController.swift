//
//  ResetPasswordViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift

final class ResetPasswordViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ResetPasswordViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
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

    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("재설정 메일 보내기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.accentColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "비밀번호 재설정"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        let descriptionLabel: UILabel = {
            let label = ResizableLabel()
            label.text = "비밀번호를 재설정할 수 있는 메일을 보내드려요"
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel
            return label
        }()

        self.navigationItem.leftBarButtonItem = self.exitButton
        self.view.addSubview(self.idField)
        self.view.addSubview(self.resetButton)
        self.view.addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
        self.idField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
        self.resetButton.snp.makeConstraints { make in
            make.top.equalTo(self.idField.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ResetPasswordViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
