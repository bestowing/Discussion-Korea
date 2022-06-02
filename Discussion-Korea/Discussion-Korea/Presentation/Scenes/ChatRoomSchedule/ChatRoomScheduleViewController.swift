//
//  ChatRoomScheduleViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import UIKit
import RxSwift
import SnapKit

final class ChatRoomScheduleViewController: UIViewController {

    // MARK: properties

    var viewModel: ChatRoomScheduleViewModel!

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    private let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.tintColor = .label
        button.accessibilityLabel = "토론 일정 추가"
        return button
    }()

    private let scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        return tableView
    }()

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
        self.title = "토론 일정"
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
        self.navigationItem.rightBarButtonItem = self.addButton
        self.view.addSubview(self.scheduleTableView)
        self.scheduleTableView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomScheduleViewModel.Input(
            viewWillAppear: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            exitTrigger: self.exitButton.rx.tap.asDriver(),
            addDiscussionTrigger: self.addButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.schedules.drive(self.scheduleTableView.rx.items) { tableView, index, model in
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell
            else { return UITableViewCell() }
            cell.bind(model)
            return cell
        }.disposed(by: self.disposeBag)

        output.exitEvent.drive().disposed(by: self.disposeBag)

        output.addDiscussionEvent.drive().disposed(by: self.disposeBag)
    }

}
