//
//  ChatRoomDetailViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/27.
//

import Combine
import UIKit

final class ChatRoomDetailViewController: UIViewController {

    @IBOutlet private weak var chatRoomName: UILabel!
    @IBOutlet private weak var calendarButton: UIButton!
    @IBOutlet private weak var userListTableView: UITableView!

    private var cancellables = Set<AnyCancellable>()
    private var userList: [UserInfo] = []
    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userListTableView.dataSource = self
        self.chatRoomName.text = "대한민국 정치 토론방"
        self.observeUserInfo()
    }

    private func observeUserInfo() {
        self.repository.observeUserInfo().sink { [weak self] userInfo in
            self?.userList.append(userInfo)
            self?.userListTableView.reloadData()
        }.store(in: &self.cancellables)
    }

}

extension ChatRoomDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as? UserListTableViewCell
        cell?.bind(with: userList[indexPath.item])
        return cell ?? UserListTableViewCell()
    }

}
