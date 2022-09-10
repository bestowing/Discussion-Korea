//
//  OtherProfileViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/10.
//

import RxSwift
import SnapKit
import UIKit

final class OtherProfileViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ReadProfileViewModel!

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDefaultProfileImage()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .accentColor
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let label = ResizableLabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    private let debateScoreView: DebateScoreView = {
        let view = DebateScoreView()
        return view
    }()

    private let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "exclamationmark.shield.fill"), for: .normal)
        button.tintColor = UIColor.systemYellow
        return button
    }()

    private let exitButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .accentColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
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
        self.view.addSubview(self.profileImageView)
        self.view.addSubview(self.nicknameLabel)
        self.view.addSubview(self.debateScoreView)
        self.view.addSubview(self.reportButton)
        self.view.addSubview(self.exitButton)
        self.profileImageView.snp.contentHuggingHorizontalPriority = 999
        self.profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.size.equalTo(60)
        }
        self.nicknameLabel.snp.contentHuggingHorizontalPriority = 1
        self.nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            make.leading.greaterThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalTo(self.profileImageView)
        }
        self.debateScoreView.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        self.reportButton.snp.makeConstraints { make in
            make.top.equalTo(self.debateScoreView.snp.bottom).offset(20)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        self.exitButton.snp.makeConstraints { make in
            make.top.equalTo(self.reportButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ReadProfileViewModel.Input(
            reportTrigger: self.reportButton.rx.tap.asDriver(),
            settingTrigger: Observable.empty().asDriverOnErrorJustComplete(),
            profileEditTrigger: Observable.empty().asDriverOnErrorJustComplete(),
            exitTrigger: self.exitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.score.drive(self.debateScoreView.rx.score)
            .disposed(by: self.disposeBag)

        output.profileURL.drive(self.profileImageView.rx.url)
            .disposed(by: self.disposeBag)

        output.nickname.drive(self.nicknameLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
