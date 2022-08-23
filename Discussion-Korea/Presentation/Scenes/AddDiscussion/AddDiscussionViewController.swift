//
//  AddDiscussionViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import UIKit
import RxSwift
import SnapKit

final class AddDiscussionViewController: UIViewController {

    // MARK: properties

    var viewModel: AddDiscussionViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let submitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.tintColor = .label
        button.accessibilityLabel = "토론 추가"
        return button
    }()

    private let topicTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }()

    private let introTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        return label
    }()

    private let introStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 1.0
        stepper.stepValue = 1.0
        stepper.minimumValue = 1.0
        stepper.maximumValue = 15.0
        return stepper
    }()

    private let mainTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        return label
    }()

    private let mainStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 1.0
        stepper.stepValue = 1.0
        stepper.minimumValue = 1.0
        stepper.maximumValue = 15.0
        return stepper
    }()

    private let conclusionTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        return label
    }()

    private let conclusionStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.value = 1.0
        stepper.stepValue = 1.0
        stepper.minimumValue = 1.0
        stepper.maximumValue = 15.0
        return stepper
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = 1
        picker.contentHorizontalAlignment = .trailing
        return picker
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
        self.title = "토론 추가"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.submitButton
        let stackView = UIStackView()
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0

        let topicStackView = UIStackView()
        stackView.addArrangedSubview(topicStackView)
        topicStackView.axis = .horizontal
        topicStackView.alignment = .center
        topicStackView.distribution = .fill
        topicStackView.spacing = 50.0

        let topicLabel = UILabel()
        topicLabel.text = "주제"
        topicLabel.font = UIFont.preferredFont(forTextStyle: .body)
        topicStackView.addArrangedSubview(topicLabel)
        topicStackView.addArrangedSubview(self.topicTextfield)

        let introStackView = UIStackView()
        stackView.addArrangedSubview(introStackView)
        introStackView.axis = .horizontal
        introStackView.alignment = .center
        introStackView.distribution = .fillProportionally
        introStackView.spacing = 0

        let introLabel = UILabel()
        introLabel.text = "입론"
        introLabel.font = UIFont.preferredFont(forTextStyle: .body)
        let minuteLabel = UILabel()
        minuteLabel.text = "분"
        minuteLabel.font = UIFont.preferredFont(forTextStyle: .body)

        introStackView.addArrangedSubview(introLabel)
        introStackView.addArrangedSubview(self.introTimeLabel)
        introStackView.addArrangedSubview(minuteLabel)
        introStackView.addArrangedSubview(self.introStepper)

        let mainStackView = UIStackView()
        stackView.addArrangedSubview(mainStackView)
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 0

        let mainLabel = UILabel()
        mainLabel.text = "본론"
        mainLabel.font = UIFont.preferredFont(forTextStyle: .body)
        let minuteLabel2 = UILabel()
        minuteLabel2.text = "분"
        minuteLabel2.font = UIFont.preferredFont(forTextStyle: .body)

        mainStackView.addArrangedSubview(mainLabel)
        mainStackView.addArrangedSubview(self.mainTimeLabel)
        mainStackView.addArrangedSubview(minuteLabel2)
        mainStackView.addArrangedSubview(self.mainStepper)

        let conclusionLabel = UILabel()
        conclusionLabel.text = "결론"
        conclusionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        let minuteLabel3 = UILabel()
        minuteLabel3.text = "분"
        minuteLabel3.font = UIFont.preferredFont(forTextStyle: .body)

        let conclusionStackView = UIStackView(
            arrangedSubviews: [conclusionLabel,
                               self.conclusionTimeLabel,
                               minuteLabel3,
                               self.conclusionStepper]
        )
        stackView.addArrangedSubview(conclusionStackView)
        conclusionStackView.axis = .horizontal
        conclusionStackView.alignment = .center
        conclusionStackView.distribution = .fillProportionally
        conclusionStackView.spacing = 0

        let dateStackView = UIStackView()
        stackView.addArrangedSubview(dateStackView)
        dateStackView.axis = .vertical
        dateStackView.alignment = .fill
        dateStackView.distribution = .fillProportionally
        dateStackView.spacing = 5

        let dateLabel = UILabel()
        dateLabel.text = "시작 날짜"
        dateLabel.font = UIFont.preferredFont(forTextStyle: .body)
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(self.datePicker)

        self.topicTextfield.snp.contentHuggingHorizontalPriority = 249
        self.topicTextfield.snp.contentHuggingVerticalPriority = 249
        dateLabel.snp.contentHuggingHorizontalPriority = 251
        dateLabel.snp.contentHuggingVerticalPriority = 251
        dateLabel.snp.contentCompressionResistanceHorizontalPriority = 752
        self.datePicker.snp.contentHuggingHorizontalPriority = 249
        self.datePicker.snp.contentHuggingVerticalPriority = 249

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = AddDiscussionViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            title: self.topicTextfield.rx.text.orEmpty.asDriver(),
            introTime: self.introStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            mainTime: self.mainStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            conclusionTime: self.conclusionStepper.rx.value
                .map { Int($0) }
                .asDriverOnErrorJustComplete(),
            date: self.datePicker.rx.value.asDriver(),
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

        output.dismiss.drive()
            .disposed(by: self.disposeBag)
    }

}
