//
//  HomeViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import RxGesture
import RxSwift
import SnapKit
import UIKit

final class HomeViewController: BaseViewController {

    // MARK: - properties

    var viewModel: HomeViewModel!

    private let nicknameLabel: UILabel = {
        let label = ResizableLabel()
        label.text = "guest"
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    private let chartButton: HomeMenuButton = {
        let button = HomeMenuButton()
        button.titleLabel.text = "방구석 조직도"
        button.imageView.image = UIImage(systemName: "rectangle.fill.badge.person.crop")
        return button
    }()

    private let lawButton: HomeMenuButton = {
        let button = HomeMenuButton()
        button.titleLabel.text = "방구석 헌법"
        button.imageView.image = UIImage(systemName: "book.closed.fill")
        return button
    }()

    private let guideButton: UIButton = {
        let button = UIButton()
        button.setTitle("방구석 가이드", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.setTitleColor(UIColor.label, for: .normal)
        button.layer.cornerRadius = 5.0
        button.layer.borderWidth = 0.7
        button.layer.borderColor = UIColor.systemGray3.cgColor
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
        let buttonStackView = UIStackView(arrangedSubviews: [
            self.chartButton, self.lawButton, UIView()
        ])
        buttonStackView.alignment = .fill
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10.0
        buttonStackView.distribution = .fillEqually
        let stackView = UIStackView(arrangedSubviews: [
            self.nicknameLabel, buttonStackView, self.guideButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(20)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = HomeViewModel.Input(
            chartTrigger: self.chartButton.rx.tapGesture().when(.recognized).map { _ in }
                .asDriverOnErrorJustComplete(),
            lawTrigger: self.lawButton.rx.tapGesture().when(.recognized).map { _ in }
                .asDriverOnErrorJustComplete(),
            guideTrigger: self.guideButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.nickname.drive(self.nicknameLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}

final class HomeMenuButton: UIView {

    fileprivate let titleLabel: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.adjustsFontSizeToFitWidth = true
        title.adjustsFontForContentSizeCategory = true
        title.textColor = .label
        return title
    }()

    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }

    private func setSubviews() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.7
        self.layer.borderColor = UIColor.systemGray3.cgColor
        self.addSubview(self.titleLabel)
        self.addSubview(self.imageView)
        self.titleLabel.snp.contentHuggingVerticalPriority = 999
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }
        self.imageView.snp.contentHuggingVerticalPriority = 1
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(self.imageView.snp.width)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width)
        }
    }

}
