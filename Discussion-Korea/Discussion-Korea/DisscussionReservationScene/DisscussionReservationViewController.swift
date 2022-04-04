//
//  DisscussionReservationViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/04.
//

import Combine
import UIKit

struct DisscussionSchedule {

    var ID: String
    var date: Date
    var duration: Int
    var topic: String

}

final class DisscussionReservationViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var cancellables = Set<AnyCancellable>()
    private var schedules: [DisscussionSchedule] = []
    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )
    private let identifier = "AddDisscussionSchedule"

    var isAdmin: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.observeSchedules()
    }

    private func observeSchedules() {
        self.repository.observeSchedules().sink { [weak self] schedule in
            self?.schedules.append(schedule)
            self?.tableView.reloadData()
        }.store(in: &self.cancellables)
    }

    @IBAction private func addButton(_ sender: UIBarButtonItem) {
        guard let isAdmin = self.isAdmin,
              isAdmin == true
        else { return }
        self.performSegue(withIdentifier: self.identifier, sender: sender)
    }

    @IBAction private func exitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

}

extension DisscussionReservationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schedules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationTableViewCell") as? ReservationTableViewCell
        let schedule = self.schedules[indexPath.item]
        cell?.bind(with: schedule) { [weak self] in
            guard let isAdmin = self?.isAdmin,
                  isAdmin == true
            else { return }
            self?.repository.cancleSchedule(by: schedule.ID)
            self?.schedules.remove(at: indexPath.item)
            self?.tableView.reloadData()
        }
        return cell ?? ReservationTableViewCell()
    }

}
