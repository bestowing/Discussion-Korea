//
//  SettingViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit
import RxSwift

final class SettingViewController: UIViewController {

    // MARK: - properties

    var viewModel: SettingViewModel!

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {}

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SettingViewModel.Input()
        _ = self.viewModel.transform(input: input)
    }

}
