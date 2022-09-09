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
        label.textColor = .label
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
        let stackView = UIStackView(arrangedSubviews: [
            self.articleLabel, self.titleLabel, self.contentsLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.edges.equalTo(scrollView)
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
