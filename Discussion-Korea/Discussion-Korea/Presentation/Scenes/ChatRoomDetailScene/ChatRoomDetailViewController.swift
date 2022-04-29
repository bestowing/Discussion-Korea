//
//  ChatRoomDetailViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/03/27.
//

import Combine
import UIKit
import Domain

final class ChatRoomDetailViewController: UIViewController {

    @IBOutlet private weak var chatRoomName: UILabel!
    @IBOutlet private weak var userListTableView: UITableView!

    private var cancellables = Set<AnyCancellable>()
    private var isAdmin: Bool?
    private var userList: [UserInfo] = []
    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userListTableView.dataSource = self
        self.observeChatRoomDetail()
        self.observeUserInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navi = segue.destination as? UINavigationController,
              let targetVC = navi.topViewController as? DisscussionReservationViewController
        else { return }
        targetVC.isAdmin = self.isAdmin
    }

    @IBAction func calendarButtonTouched(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toDisscussionReservationViewController", sender: sender)
    }

    private func observeChatRoomDetail() {
        self.repository.observeDetails().sink { [weak self] detail in
            self?.chatRoomName.text = detail.title
        }.store(in: &self.cancellables)

    }
    private func observeUserInfo() {
        self.repository.observeUserInfo().sink { [weak self] userInfo in
            if userInfo.userID == IDManager.shared.userID() {
                self?.isAdmin = userInfo.isAdmin
            }
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
