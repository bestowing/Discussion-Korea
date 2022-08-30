//
//  LawViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import RxSwift
import UIKit

final class LawViewController: BaseViewController {

    // MARK: - properties

    var viewModel: LawViewModel!

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
        self.title = "헌법"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = LawViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
