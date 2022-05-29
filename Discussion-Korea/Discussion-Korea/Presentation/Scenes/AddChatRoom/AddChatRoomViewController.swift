//
//  AddChatRoomViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import UIKit
import RxSwift
import SnapKit

final class AddChatRoomViewController: UIViewController {

    // MARK: properties

    var viewModel: AddChatRoomViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.tintColor = .label
        button.accessibilityLabel = "토론 추가"
        return button
    }()

    private let titleTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "채팅방 제목을 입력해주세요"
        return textField
    }()

    private let disposeBag = DisposeBag()

    // MARK: - init/deinit

    deinit {
        print("🗑", Self.description())
    }

    // MARK: - methods

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "채팅방 추가"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.submitButton

        let descriptionLabel = UILabel()
        descriptionLabel.text = "채팅방 제목을\n입력해주세요"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 27.0, weight: .semibold)
        self.view.addSubview(descriptionLabel)

        let underline = UILabel()
        underline.backgroundColor = .label
        self.view.addSubview(underline)

        self.view.addSubview(self.titleTextfield)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
        }
        self.titleTextfield.snp.makeConstraints { make in
            make.leading.equalTo(descriptionLabel.snp.leading)
            make.trailing.equalTo(descriptionLabel.snp.trailing)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
        }
        underline.snp.makeConstraints { make in
            make.leading.equalTo(self.titleTextfield.snp.leading)
            make.trailing.equalTo(self.titleTextfield.snp.trailing)
            make.top.equalTo(self.titleTextfield.snp.bottom).offset(3)
            make.height.equalTo(3)
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = AddChatRoomViewModel.Input(
            title: self.titleTextfield.rx.text.orEmpty.asDriver(),
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            submitTrigger: self.submitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.submitEnabled.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
