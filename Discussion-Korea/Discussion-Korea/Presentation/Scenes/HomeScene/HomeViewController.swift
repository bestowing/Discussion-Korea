//
//  HomeViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/17.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {

    // MARK: properties

    var viewModel: HomeViewModel!

    @IBOutlet private weak var enterChatRoomButton: UIButton!
    private let disposeBag = DisposeBag()

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = HomeViewModel.Input(
            enterChatRoomTrigger: self.enterChatRoomButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.events
            .drive().disposed(by: self.disposeBag)
    }

}
