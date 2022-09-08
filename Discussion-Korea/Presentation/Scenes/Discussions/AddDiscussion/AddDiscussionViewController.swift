//
//  AddDiscussionViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/07.
//

import UIKit
import RxSwift
import SnapKit

final class AddDiscussionViewController: BaseViewController {

    // MARK: - properties

    var viewModel: AddDiscussionViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "다음"
        button.tintColor = .label
        button.isEnabled = false
        button.accessibilityLabel = "다음으로"
        return button
    }()

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

    private let topicTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "무엇에 대한 토론인가요?"
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        }
        picker.minuteInterval = 1
        return picker
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
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.nextButton

        let stackView = UIStackView()
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(25)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(25)
        }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 40

        let titleLabel = ResizableLabel()
        titleLabel.text = "어떤 토론을 해볼까요?"
        titleLabel.font = .preferredBoldFont(forTextStyle: .title2)
        stackView.addArrangedSubview(titleLabel)

        let topicStackView = UIStackView()
        stackView.addArrangedSubview(topicStackView)
        topicStackView.axis = .vertical
        topicStackView.alignment = .fill
        topicStackView.distribution = .fill
        topicStackView.spacing = 10.0

        let topicLabel = ResizableLabel()
        topicLabel.text = "토론 주제"
        topicLabel.textColor = .secondaryLabel
        topicLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        topicStackView.addArrangedSubview(topicLabel)
        topicStackView.addArrangedSubview(self.topicTextfield)

        // TODO: 부가설명 추가하기

        let dateStackView = UIStackView()
        stackView.addArrangedSubview(dateStackView)
        dateStackView.axis = .vertical
        dateStackView.alignment = .fill
        dateStackView.distribution = .fillProportionally
        dateStackView.spacing = 10.0

        let dateLabel = ResizableLabel()
        dateLabel.text = "토론 시작 일자"
        dateLabel.textColor = .secondaryLabel
        dateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
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
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = AddDiscussionViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            title: self.topicTextfield.rx.text.orEmpty.asDriver(),
            date: self.datePicker.rx.value.asDriver(),
            nextTrigger: self.nextButton.rx.tap.asDriver()
//            introTime: Observable.empty().asDriverOnErrorJustComplete(),
//            mainTime: Observable.empty().asDriverOnErrorJustComplete(),
//            conclusionTime: Observable.empty().asDriverOnErrorJustComplete(),
//            isFullTime: Observable.just(true).asDriverOnErrorJustComplete(),
//            submitTrigger: Observable.empty().asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.nextEnabled.drive(self.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
