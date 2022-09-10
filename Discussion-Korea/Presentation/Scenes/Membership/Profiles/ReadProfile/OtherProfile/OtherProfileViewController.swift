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

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

    private let profileImageView: ProfileImageView = {
        let imageView = ProfileImageView()
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = .accentColor
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
        button.setTitle("신고", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 0, bottom: 12, trailing: 0
            )
            button.configuration = configuration
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemRed
        return button
    }()

    private let exitButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .accentColor
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 0, bottom: 12, trailing: 0
            )
            button.configuration = configuration
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "프로필 보기"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.backBarButtonItem = self.backButton
        self.view.addSubview(self.profileImageView)
        self.view.addSubview(self.nicknameLabel)
        self.view.addSubview(self.debateScoreView)
        self.view.addSubview(self.reportButton)
        self.view.addSubview(self.exitButton)
        self.profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.width.height.equalTo(100)
        }
        self.nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.bottom).offset(15)
            make.leading.greaterThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(30)
            make.trailing.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-30)
            make.centerX.equalTo(self.profileImageView)
        }
        self.debateScoreView.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(40)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
        self.reportButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(self.exitButton.snp.top).offset(-10)
        }
        self.exitButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide)
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
