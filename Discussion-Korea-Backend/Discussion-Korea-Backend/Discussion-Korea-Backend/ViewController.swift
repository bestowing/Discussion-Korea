//
//  ViewController.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/04/24.
//

import Alamofire
import Combine
import UIKit
import FirebaseDatabase

// 방 추가할때 phase 밑에 value(Int) 설정
// details 밑에 title(String)

final class ViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    private var chatRooms = [DiscussionManager]()

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
        let reference = Database
            .database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
            .reference()
        #elseif RELEASE
        let reference =
            .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
        #endif

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        reference.child("chatRooms").observe(.childAdded) { [unowned self] snapshot in
            let chatRoomID = snapshot.key
            let discussionManager = DiscussionManager(
                chatRoomID: chatRoomID, sideManager: SideManager(), dateFormatter: dateFormatter
            )
            self.chatRooms.append(discussionManager)
            discussionManager.transform().sink { _ in }.store(in: &self.cancellables)
        }

    }

}
