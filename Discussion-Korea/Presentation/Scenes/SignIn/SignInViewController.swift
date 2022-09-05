//
//  SignInViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

import UIKit

final class SignInViewController: BaseViewController {

    // MARK: - properties

    var viewModel: SignInViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = SignInViewModel.Input()
        let _ = self.viewModel.transform(input: input)
    }

}
