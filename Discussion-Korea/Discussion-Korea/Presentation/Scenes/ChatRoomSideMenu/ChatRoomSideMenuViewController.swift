//
//  ChatRoomSideMenuViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/05.
//

import UIKit
import SideMenu
import SnapKit
import RxSwift

final class ChatRoomSideMenuViewController: UIViewController {

    // MARK: properties

    var viewModel: ChatRoomSideMenuViewModel!

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()

    private let line: UILabel = {
        let line = UILabel()
        line.backgroundColor = .systemGray4
        return line
    }()

    private let calendarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    private let line2: UILabel = {
        let line = UILabel()
        line.backgroundColor = .systemGray4
        return line
    }()

    private let participantLabel: UILabel = {
        let label = UILabel()
        label.text = "참가자"
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()

    private let participantsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ParticipantCell.self,
                           forCellReuseIdentifier: ParticipantCell.identifier)
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
        self.view.backgroundColor = .systemGray6
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubViews()
        self.bindViewModel()
    }

    private func setSubViews() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.line)
        self.view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.calendarButton)
        self.view.addSubview(self.line2)
        self.view.addSubview(self.participantLabel)
        self.view.addSubview(self.participantsTableView)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
        }
        self.line.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.height.equalTo(1)
        }
        self.stackView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.trailing.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.top.equalTo(self.line.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        self.calendarButton.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        self.line2.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(self.stackView.snp.bottom).offset(20)
            make.height.equalTo(1)
        }
        self.participantLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(self.line2.snp.bottom).offset(20)
        }
        self.participantsTableView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.top.equalTo(self.participantLabel.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
    }

    private func bindViewModel() {
        assert(self.viewModel != nil)

        let input = ChatRoomSideMenuViewModel.Input(
            viewWillAppear: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            calendar: self.calendarButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)

        output.participants.drive(self.participantsTableView.rx.items) { tableView, index, model in
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantCell.identifier, for: indexPath) as? ParticipantCell
            else { return UITableViewCell() }
            cell.bind(model)
            return cell
        }.disposed(by: self.disposeBag)

        output.chatRoomTitle.drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)

        output.calendarEvent.drive()
            .disposed(by: self.disposeBag)

    }

}
