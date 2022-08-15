//
//  HomeViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit
import RxSwift

final class HomeViewController: UIViewController {

    // MARK: - properties

    var viewModel: HomeViewModel!

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

    private let scoreLabel: UILabel = {
        let label = ResizableLabel()
        label.text = "0승 0무 0패"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
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
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.view.addSubview(self.profileImageView)
        let stackView = UIStackView(
            arrangedSubviews: [self.nicknameLabel, self.scoreLabel]
        )
        stackView.axis = .vertical
        stackView.spacing = 10.0
        self.view.addSubview(stackView)
        self.profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(25)
            make.width.equalTo(60)
            make.height.equalTo(64)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-25)
            make.centerY.equalTo(self.profileImageView)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = HomeViewModel.Input()
        let output = self.viewModel.transform(input: input)

        output.nickname.drive(self.nicknameLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.score.drive(self.scoreLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.profileURL.drive(onNext: {
            self.profileImageView.setImage($0)
        })
        .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
