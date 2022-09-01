//
//  MyPageViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import RxSwift
import SnapKit
import UIKit

final class MyPageViewController: BaseViewController {

    // MARK: - properties

    var viewModel: MyPageViewModel!

    private let titleItem: UIBarButtonItem = {
        let label = UIBarButtonItem()
        label.title = "내 방구석"
        label.isEnabled = false
        label.setTitleTextAttributes(
            [.font: UIFont.boldSystemFont(ofSize: 25.0),
             NSAttributedString.Key.foregroundColor: UIColor.label],
            for: .disabled
        )
        return label
    }()

    private let settingButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "gearshape")
        button.tintColor = .label
        button.accessibilityLabel = "설정"
        return button
    }()

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

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
        label.text = "guest"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("프로필 수정", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.accentColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private let debateScoreView: DebateScoreView = {
        let view = DebateScoreView()
        return view
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.backBarButtonItem = self.backButton
        self.navigationItem.leftBarButtonItem = self.titleItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.rightBarButtonItem = self.settingButton
        self.view.addSubview(self.profileImageView)
        self.view.addSubview(self.nicknameLabel)
        self.view.addSubview(self.editButton)
        self.view.addSubview(self.debateScoreView)
        self.profileImageView.snp.contentHuggingHorizontalPriority = 999
        self.profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.size.equalTo(60)
        }
        self.nicknameLabel.snp.contentHuggingHorizontalPriority = 1
        self.nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.centerY.equalTo(self.profileImageView)
        }
        self.editButton.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        self.debateScoreView.snp.makeConstraints { make in
            make.top.equalTo(self.editButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = MyPageViewModel.Input(
            settingTrigger: self.settingButton.rx.tap.asDriver(),
            profileEditTrigger: self.editButton.rx.tap.asDriver()
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
