//
//  ChatRoomDetailViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/27.
//

import UIKit

final class ChatRoomDetailViewController: UIViewController {

    @IBOutlet private weak var chatRoomName: UILabel!
    @IBOutlet private weak var calendarButton: UIButton!
    @IBOutlet private weak var userListTableView: UITableView!
    private var userList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userListTableView.dataSource = self
        self.chatRoomName.text = "대한민국 정치 토론방"
        self.userList = ["청수", "제임스"]
    }

}

extension ChatRoomDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as? UserListTableViewCell
        cell?.bind(nickname: userList[indexPath.item])
        return cell ?? UserListTableViewCell()
    }

}
