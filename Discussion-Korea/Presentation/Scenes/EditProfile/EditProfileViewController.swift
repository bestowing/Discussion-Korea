//
//  EnterGuestViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import SnapKit
import UIKit
import RxSwift

final class EditProfileViewController: BaseViewController {

    // MARK: - properties

    var viewModel: EditProfileViewModel!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .white
        indicator.backgroundColor = .gray
        indicator.layer.cornerRadius = 10.0
        return indicator
    }()

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.tintColor = .label
        return button
    }()

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "취소"
        button.tintColor = .label
        return button
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDefaultProfileImage()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 70
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nicknameTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "닉네임을 입력해주세요"
        return textField
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func loadView() {
        super.loadView()
        self.title = "프로필 수정"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.submitButton

        let profileBadge = UIImageView()
        profileBadge.image = UIImage(systemName: "camera.circle.fill")
        profileBadge.tintColor = .label
        profileBadge.layer.cornerRadius = 20
        profileBadge.layer.masksToBounds = true
        profileBadge.backgroundColor = .systemBackground

        let divisor = UILabel()
        divisor.backgroundColor = .label

        self.view.addSubview(divisor)
        self.view.addSubview(self.profileImageView)
        self.view.addSubview(profileBadge)
        self.view.addSubview(self.nicknameTextfield)

        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center

        self.profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.width.equalTo(140)
            make.height.equalTo(142)
        }
        profileBadge.snp.makeConstraints { make in
            make.trailing.equalTo(self.profileImageView.snp.trailing)
            make.bottom.equalTo(self.profileImageView.snp.bottom)
            make.size.equalTo(40)
        }
        self.nicknameTextfield.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-25)
            make.top.equalTo(self.profileImageView.snp.bottom).offset(30)
        }
        divisor.snp.makeConstraints { make in
            make.leading.equalTo(self.nicknameTextfield.snp.leading)
            make.trailing.equalTo(self.nicknameTextfield.snp.trailing)
            make.top.equalTo(self.nicknameTextfield.snp.bottom).offset(3)
            make.height.equalTo(3)
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let tapGesture = UITapGestureRecognizer()
        self.profileImageView.addGestureRecognizer(tapGesture)

        let input = EditProfileViewModel.Input(
            nickname: self.nicknameTextfield.rx.text.orEmpty
                .asDriverOnErrorJustComplete(),
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            imageTrigger: tapGesture.rx.event.asDriver().mapToVoid(),
            submitTrigger: self.submitButton.rx.tap.asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.loading.drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        output.oldNickname.drive(self.nicknameTextfield.rx.text)
            .disposed(by: self.disposeBag)

        output.profileURL.drive(self.profileImageView.rx.url)
            .disposed(by: self.disposeBag)

        output.submitEnable.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
