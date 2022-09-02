//
//  LawDetailViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/02.
//

import RxSwift
import UIKit

final class LawDetailViewController: BaseViewController {

    // MARK: - properties

    var viewModel: LawDetailViewModel!

    private let articleLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        return label
    }()

    private let titleLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .title1)
        label.numberOfLines = 0
        return label
    }()

    private let contentsLabel: UILabel = {
        let label = ResizableLabel()
        label.font = UIFont.preferredBoldFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.view.addSubview(self.articleLabel)
        self.view.addSubview(self.titleLabel)
        self.articleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.articleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self.articleLabel)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = LawDetailViewModel.Input()
        let output = self.viewModel.transform(input: input)

        output.law.map { "제\($0.article)조" }.drive(self.articleLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.law.map { $0.topic }.drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.law.map { $0.contents }.drive(self.contentsLabel.rx.text)
            .disposed(by: self.disposeBag)
    }

}
