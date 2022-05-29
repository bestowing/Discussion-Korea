//
//  EnterGuestViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import SnapKit
import UIKit
import RxSwift

final class EnterGuestViewController: UIViewController {

    // MARK: - properties

    var viewModel: EnterGuestViewModel!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .white
        indicator.backgroundColor = .gray
        indicator.layer.cornerRadius = 10.0
        return indicator
    }()

    private let guestButton: UIButton = {
        let button = UIButton()
        button.setTitle("일단 둘러볼게요", for: .normal)
        button.backgroundColor = .primaryColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.tintColor = .label
        return button
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDefaultProfileImage()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .primaryColor
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

    // MARK: - init/deinit

    deinit {
        print("🗑", Self.description())
    }

    // MARK: - methods

    override func loadView() {
        super.loadView()
        self.title = "처음 설정하기"
        self.view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.rightBarButtonItem = self.submitButton

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "안녕하세요, 처음 오신 것 같군요!\n시작하기 전에 프로필 사진과 닉네임을 설정해주세요."
        descriptionLabel.font = UIFont.systemFont(ofSize: 20.0)

        let profileBadge = UIImageView()
        profileBadge.image = UIImage(systemName: "camera.circle.fill")
        profileBadge.tintColor = .label
        profileBadge.layer.cornerRadius = 20
        profileBadge.layer.masksToBounds = true
        profileBadge.backgroundColor = .white

        let divisor = UILabel()
        divisor.backgroundColor = .label

        self.view.addSubview(descriptionLabel)
        self.view.addSubview(divisor)
        self.view.addSubview(self.guestButton)
        self.view.addSubview(self.profileImageView)
        self.view.addSubview(profileBadge)
        self.view.addSubview(self.nicknameTextfield)

        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-25)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(25)
        }
        self.guestButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-25)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-25)
            make.height.equalTo(50)
        }
        self.profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
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

        let input = EnterGuestViewModel.Input(
            nickname: self.nicknameTextfield.rx.text.orEmpty
                .asDriverOnErrorJustComplete(),
            imageTrigger: tapGesture.rx.event.asDriver().mapToVoid(),
            guestTrigger: self.guestButton.rx.tap.asDriverOnErrorJustComplete(),
            submitTrigger: self.submitButton.rx.tap.asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.loading.drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        output.profileImage.drive { [unowned self] url in
            guard let url = url
            else { return }
            self.profileImageView.setImage(url)
        }.disposed(by: self.disposeBag)

        output.submitEnable.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
