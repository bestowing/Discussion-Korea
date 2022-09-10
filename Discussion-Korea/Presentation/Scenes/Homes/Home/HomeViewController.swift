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

    private let userInfoPanel: UserInfoPanel = {
        let panel = UserInfoPanel()
        panel.formatter = { day in "함께한지 \(day + 1)일째" }
        return panel
    }()

    private let chartButton: HomeMenuButton = {
        let button = HomeMenuButton()
        button.isEnabled = false
        button.titleLabel.text = "방구석 조직도"
        button.imageView.image = UIImage(systemName: "rectangle.stack.fill.badge.person.crop")
        return button
    }()

    private let lawButton: HomeMenuButton = {
        let button = HomeMenuButton()
        button.isEnabled = true
        button.titleLabel.text = "방구석 헌법"
        button.imageView.image = UIImage(systemName: "book.fill")
        return button
    }()

    private let guideButton: HomeMenuButton = {
        let button = HomeMenuButton()
        button.isEnabled = true
        button.titleLabel.text = "방구석 가이드"
        button.imageView.image = UIImage(systemName: "questionmark.circle")
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
            self.chartButton, self.lawButton, self.guideButton
        ])
        buttonStackView.alignment = .fill
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10.0
        buttonStackView.distribution = .fillEqually
        let stackView = UIStackView(arrangedSubviews: [
            self.nicknameLabel, self.userInfoPanel, buttonStackView
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
            chartTrigger: self.chartButton.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            lawTrigger: self.lawButton.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            guideTrigger: self.guideButton.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.nickname.drive(self.nicknameLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.day.drive(self.userInfoPanel.rx.day)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
