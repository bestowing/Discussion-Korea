//
//  HomeViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SnapKit
import UIKit
import RxSwift

final class HomeViewController: UIViewController {

    // MARK: - properties

    var viewModel: HomeViewModel!

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
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {}

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = HomeViewModel.Input()
        _ = self.viewModel.transform(input: input)
    }

}
