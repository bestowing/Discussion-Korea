//
//  SettingViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/19.
//

import SnapKit
import UIKit

final class SettingViewController: UIViewController {

    // MARK: - properties

    var contents = [String]()
    var selected = [() -> Void]()

    private let backButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = ""
        button.tintColor = .label
        button.style = .plain
        return button
    }()

    private let settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

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
        self.setSubViews()
    }

    private func setSubViews() {
        self.navigationItem.backBarButtonItem = self.backButton
        self.view.addSubview(self.settingTableView)
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.settingTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}

extension SettingViewController: UITableViewDelegate,
                                 UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected[indexPath.item]()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        else {
            return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.selectionStyle = .none
        self.setText(with: self.contents[indexPath.item], to: cell)
        return cell
    }

    private func setText(with text: String, to cell: UITableViewCell) {
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = text
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = text
        }
    }

}
