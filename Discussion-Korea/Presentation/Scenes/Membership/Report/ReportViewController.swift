//
//  ReportViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

import RxSwift
import UIKit

final class ReportViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ReportViewModel!

    private let reportReasonTextfield: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "신고 사유 (선택 사항)"
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("제출", for: .normal)
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
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        let stackView = UIStackView()
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(25)
            make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(25)
        }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20

        let titleLabel = ResizableLabel()
        titleLabel.text = "신고하려는 이유가 무엇인가요?"
        titleLabel.font = .preferredBoldFont(forTextStyle: .title2)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(self.reportReasonTextfield)
        stackView.addArrangedSubview(self.sendButton)

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ReportViewModel.Input(
            reportReason: self.reportReasonTextfield.rx.text.orEmpty.asDriver(),
            sendEvent: self.sendButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
