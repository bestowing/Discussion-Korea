//
//  ChatRoomCoverViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/13.
//

import UIKit
import RxSwift

final class ChatRoomCoverViewController: BaseViewController {

    // MARK: - properties

    var viewModel: ChatRoomCoverViewModel!

    private let disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)
    }

}
