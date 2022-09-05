//
//  ChartViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import RxSwift
import UIKit

final class ChartViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChartViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let sorryLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.text = "준비중입니다 😢"
        label.textColor = .systemGray2
        return label
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "조직도"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.view.addSubview(self.sorryLabel)
        self.sorryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChartViewModel.Input(
            exitTrigger: self.exitButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.events.drive()
            .disposed(by: self.disposeBag)
    }

}
