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

    var viewModel: ConfigureProfileViewModel!

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

    private let profileView = ConfigureProfileView()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "프로필 수정"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.submitButton

        self.view.addSubview(self.profileView)
        self.profileView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)

        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ConfigureProfileViewModel.Input(
            nickname: self.profileView.rx.nickname.orEmpty
                .asDriverOnErrorJustComplete()
                .skip(1),
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            imageTrigger: self.profileView.rx.tapImage.asDriverOnErrorJustComplete(),
            submitTrigger: self.submitButton.rx.tap.asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.loading.drive(self.activityIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)

        output.oldNickname.drive(self.profileView.rx.nickname)
            .disposed(by: self.disposeBag)

        output.profileURL.drive(self.profileView.rx.url)
            .disposed(by: self.disposeBag)

        output.submitEnable.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
