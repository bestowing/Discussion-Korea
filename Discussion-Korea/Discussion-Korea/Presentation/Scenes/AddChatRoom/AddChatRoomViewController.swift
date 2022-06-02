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

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.tintColor = .label
        button.accessibilityLabel = "토론 추가"
        return button
    }()

    private let chatRoomProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDefaultChatRoomProfileImage()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .center
        imageView.backgroundColor = .primaryColor
        imageView.layer.cornerRadius = 70
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
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
        self.title = "채팅방 추가"
        self.view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.submitButton

        let descriptionLabel = UILabel()
        descriptionLabel.text = "채팅방 제목과\n사진을 설정해주세요"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 27.0, weight: .semibold)
        self.view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
        }

        self.view.addSubview(self.chatRoomProfileImageView)
        self.chatRoomProfileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.width.equalTo(140)
            make.height.equalTo(142)
        }

        // MARK: 프로필 뱃지
        let profileBadge = UIImageView()
        profileBadge.image = UIImage(systemName: "camera.circle.fill")
        profileBadge.tintColor = .label
        profileBadge.layer.cornerRadius = 20
        profileBadge.layer.masksToBounds = true
        profileBadge.backgroundColor = .white
        self.view.addSubview(profileBadge)
        profileBadge.snp.makeConstraints { make in
            make.trailing.equalTo(self.chatRoomProfileImageView.snp.trailing)
            make.bottom.equalTo(self.chatRoomProfileImageView.snp.bottom)
            make.size.equalTo(40)
        }

        self.view.addSubview(self.titleTextfield)
        self.titleTextfield.snp.makeConstraints { make in
            make.leading.equalTo(descriptionLabel.snp.leading)
            make.trailing.equalTo(descriptionLabel.snp.trailing)
            make.top.equalTo(self.chatRoomProfileImageView.snp.bottom).offset(30)
        }

        // MARK: 밑줄
        let underline = UILabel()
        underline.backgroundColor = .label
        self.view.addSubview(underline)
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

        let tapGesture = UITapGestureRecognizer()
        self.chatRoomProfileImageView.addGestureRecognizer(tapGesture)

        let input = AddChatRoomViewModel.Input(
            title: self.titleTextfield.rx.text.orEmpty.asDriver(),
            imageTrigger: tapGesture.rx.event.asDriver().mapToVoid(),
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            submitTrigger: self.submitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.profileImage.drive { [unowned self] url in
            guard let url = url
            else { return }
            self.chatRoomProfileImageView.setImage(url)
            self.chatRoomProfileImageView.contentMode = .scaleAspectFill
        }.disposed(by: self.disposeBag)

        output.submitEnabled.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
