//
//  ChatRoomCoverViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/13.
//

import RxSwift
import UIKit

final class ChatRoomCoverViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChatRoomCoverViewModel!

    private let chatRoomProfileImageView: ChatRoomProfileImageView = {
        let imageView = ChatRoomProfileImageView()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .center
        imageView.backgroundColor = .accentColor
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = ResizableLabel()
        label.textColor = .label
        label.font = .preferredBoldFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.accessibilityLabel = "채팅방 제목"
        return label
    }()

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고 및 차단", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 0, bottom: 12, trailing: 0
            )
            configuration.baseBackgroundColor = .systemRed
            configuration.cornerStyle = .medium
            button.configuration = configuration
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            button.backgroundColor = .systemRed
            button.layer.cornerRadius = 7
        }
        return button
    }()

    private let participateButton: UIButton = {
        let button = UIButton()
        button.setTitle("입장하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.titleAlignment = .center
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 0, bottom: 12, trailing: 0
            )
            configuration.baseBackgroundColor = .accentColor
            configuration.cornerStyle = .medium
            button.configuration = configuration
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            button.backgroundColor = .accentColor
            button.layer.cornerRadius = 7
        }
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
        self.navigationItem.leftBarButtonItem = self.exitButton

        self.view.addSubview(self.chatRoomProfileImageView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.reportButton)
        self.view.addSubview(self.participateButton)
        self.chatRoomProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.size.equalTo(100)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.chatRoomProfileImageView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        self.reportButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(self.participateButton.snp.top).offset(-10)
        }
        self.participateButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomCoverViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            reportTrigger: self.reportButton.rx.tap.asDriver(),
            participateTrigger: self.participateButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.title.drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.profileURL.drive(self.chatRoomProfileImageView.rx.url)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
