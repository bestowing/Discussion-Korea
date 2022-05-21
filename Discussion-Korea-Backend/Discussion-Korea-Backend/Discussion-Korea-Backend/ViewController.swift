//
//  ViewController.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/04/24.
//

import Alamofire
import Combine
import UIKit

// 방 추가할때 phase 밑에 value(Int) 설정
// details 밑에 title(String)

final class ViewController: UIViewController {

    private let discussionManager: DiscussionManager = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return DiscussionManager(
            sideManager: SideManager(),
            dateFormatter: dateFormatter
        )
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.discussionManager.transform()
            .sink { _ in }
            .store(in: &self.cancellables)
    }

}
