//
//  SignUpViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit
import RxSwift

final class SignUpViewController: BaseViewController {

    // MARK: - properties

    var viewModel: SignUpViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
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
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SignUpViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriverOnErrorJustComplete()
        )
        let output = self.viewModel.transform(input: input)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
