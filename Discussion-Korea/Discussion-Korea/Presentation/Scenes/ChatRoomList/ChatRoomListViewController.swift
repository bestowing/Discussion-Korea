//
//  ChatRoomListViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit
import RxSwift

final class ChatRoomListViewController: UIViewController {

    // MARK: properties

    var viewModel: ChatRoomListViewModel!

    private let enterChatRoomButton: UIButton = {
        let button = UIButton()
        button.setTitle("이동하기", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        return button
    }()

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

    private let disposeBag = DisposeBag()

    // MARK: - init/deinit

    deinit {
        print(#function, self)
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

    private func setSubViews() {
        self.navigationItem.backBarButtonItem = self.backButton
        self.view.addSubview(self.enterChatRoomButton)
        self.enterChatRoomButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomListViewModel.Input(
            enterChatRoomTrigger: self.enterChatRoomButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.events
            .drive().disposed(by: self.disposeBag)
    }

}
