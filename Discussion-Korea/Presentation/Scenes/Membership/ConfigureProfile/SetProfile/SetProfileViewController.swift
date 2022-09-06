//
//  SetProfileViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/07.
//

import UIKit
import RxCocoa
import RxSwift

final class SetProfileViewController: BaseViewController {

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

    private let profileView = ConfigureProfileView()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "프로필 설정"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.rightBarButtonItem = self.submitButton

        let stackView = UIStackView(arrangedSubviews: [
            {
                let label = ResizableLabel()
                label.numberOfLines = 0
                label.text = "안녕하세요!"
                label.font = UIFont.preferredBoldFont(forTextStyle: .headline)
                return label
            }(),
            {
                let label = ResizableLabel()
                label.numberOfLines = 0
                label.text = "처음 오신 것 같네요.\n프로필 사진과 닉네임을 설정해주세요"
                label.textColor = .secondaryLabel
                label.font = UIFont.preferredFont(forTextStyle: .body)
                return label
            }()
        ])
        stackView.axis = .vertical
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }

        self.view.addSubview(self.profileView)
        self.profileView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(stackView)
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
            exitTrigger: Driver.never(),
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
