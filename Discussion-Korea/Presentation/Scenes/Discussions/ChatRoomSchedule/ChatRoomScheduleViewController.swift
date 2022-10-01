//
//  ChatRoomScheduleViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import UIKit
import ReactorKit
import RxSwift
import SnapKit

final class ChatRoomScheduleViewController: BaseViewController, View {
    // MARK: - properties

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
        tableView.register(
            ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier
        )
        return tableView
    }()

    var disposeBag = DisposeBag()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "토론 일정"
        self.setSubViews()
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

    func bind(reactor: ChatRoomScheduleReactor) {
        self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.exitButton.rx.tap
            .map { Reactor.Action.exitTrigger }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap
            .map { Reactor.Action.addDiscussionTrigger }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.asObservable().map { $0.schedules }
            .bind(to: self.scheduleTableView.rx.items) { tableView, index, model in
                let indexPath = IndexPath(item: index, section: 0)
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell
                else { return UITableViewCell() }
                cell.bind(model)
                return cell
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.asObservable().map { $0.addEnabled }
            .bind(to: self.addButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
