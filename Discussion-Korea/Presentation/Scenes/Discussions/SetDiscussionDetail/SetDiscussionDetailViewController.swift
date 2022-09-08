//
//  SetDiscussionTimeViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/08.
//

import UIKit
import RxSwift

final class SetDiscussionDetailViewController: BaseViewController {

    // MARK: - properties

    var viewModel: SetDiscussionDetailViewModel!

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "제출"
        button.tintColor = .label
        button.isEnabled = false
        button.accessibilityLabel = "토론 추가"
        return button
    }()

    private let introTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        label.textAlignment = .right
        return label
    }()

    private let introStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 2.0
        stepper.stepValue = 2.0
        stepper.minimumValue = 2.0
        stepper.maximumValue = 20.0
        return stepper
    }()

    private let mainTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        label.textAlignment = .right
        return label
    }()

    private let mainStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 5.0
        stepper.stepValue = 5.0
        stepper.minimumValue = 5.0
        stepper.maximumValue = 20.0
        return stepper
    }()

    private let conclusionTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title3)
        label.textAlignment = .right
        return label
    }()

    private let conclusionStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 2.0
        stepper.stepValue = 2.0
        stepper.minimumValue = 2.0
        stepper.maximumValue = 20.0
        return stepper
    }()

    private let fulltimeSwitch = UISwitch()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.rightBarButtonItem = self.submitButton

        let stackView = { () -> UIStackView in
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 40
            return stackView
        }()
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(25)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(25)
        }

        stackView.addArrangedSubview(
            {
                let label = ResizableLabel()
                label.text = "얼마나 길게 토론을 할까요?"
                label.font = .preferredBoldFont(forTextStyle: .title2)
                return label
            }()
        )

        stackView.addArrangedSubview(
            {
                let stackView = UIStackView(arrangedSubviews: [
                    {
                        let label = UILabel()
                        label.text = "입론"
                        label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.textColor = .secondaryLabel
                        return label
                    }(),
                    self.introTimeLabel,
                    self.introStepper
                ])
                stackView.axis = .horizontal
                stackView.spacing = 15
                return stackView
            }()
        )

        stackView.addArrangedSubview(
            { () -> UIStackView in
                let stackView = UIStackView(arrangedSubviews: [
                    {
                        let label = UILabel()
                        label.text = "본론"
                        label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.textColor = .secondaryLabel
                        return label
                    }(),
                    self.mainTimeLabel,
                    self.mainStepper
                ])
                stackView.axis = .horizontal
                stackView.spacing = 15
                return stackView
            }()
        )

        stackView.addArrangedSubview(
            {
                let stackView = UIStackView(arrangedSubviews: [
                    {
                        let conclusionLabel = UILabel()
                        conclusionLabel.text = "결론"
                        conclusionLabel.font = UIFont.preferredFont(forTextStyle: .body)
                        conclusionLabel.textColor = .secondaryLabel
                        return conclusionLabel
                    }(),
                    self.conclusionTimeLabel,
                    self.conclusionStepper
                ])
                stackView.axis = .horizontal
                stackView.spacing = 15
                return stackView
            }()
        )

        stackView.addArrangedSubview(
            {
                let fulltimeStackView = UIStackView(arrangedSubviews: [
                    {
                        let fulltimeLabel = UILabel()
                        fulltimeLabel.text = "후반전 활성화"
                        fulltimeLabel.textColor = .secondaryLabel
                        return fulltimeLabel
                    }(),
                    self.fulltimeSwitch
                ])
                fulltimeStackView.axis = .horizontal
                fulltimeStackView.spacing = 0
                return fulltimeStackView
            }()
        )
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SetDiscussionDetailViewModel.Input(
            introTime: self.introStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            mainTime: self.mainStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            conclusionTime: self.conclusionStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            isFullTime: self.fulltimeSwitch.rx.value.asDriver(),
            submitTrigger: self.submitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.submitEnabled.drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.intro.drive(self.introTimeLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        output.main.drive(self.mainTimeLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        output.conclusion.drive(self.conclusionTimeLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
