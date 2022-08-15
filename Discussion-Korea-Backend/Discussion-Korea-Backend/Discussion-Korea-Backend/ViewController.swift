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

enum ReferenceManager {

//    static let reference = Database
//        .database(url: "http://localhost:9000?ns=test-3dbd4-default-rtdb")
//        .reference()
    static let reference = Database
        .database(url: "https://test-3dbd4-default-rtdb.asia-southeast1.firebasedatabase.app")
        .reference()

}

// 방 추가할때 phase 밑에 value(Int) 설정
// details 밑에 title(String)

final class ViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    private var chatRooms = [DiscussionManager]()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserInfoManager.shared.observe()
        let reference = ReferenceManager.reference

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        reference.child("chatRooms").observe(.childAdded) { [unowned self] snapshot in
            let chatRoomID = snapshot.key
            let discussionManager = DiscussionManager(
                chatRoomID: chatRoomID, sideManager: SideManager(chatRoomID: chatRoomID), dateFormatter: dateFormatter
            )
            self.chatRooms.append(discussionManager)
            discussionManager.transform().sink { _ in }.store(in: &self.cancellables)
        }

    }

//    private func test() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let summaryManager = SummaryManager(dateFormatter: dateFormatter, reference: Database.database().reference())
//        summaryManager.add(chat: Chat(userID: "a1", content: "저도 찬성입니다. 대학을 가면 연애를 할 수 있기 때문이죠."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "a1", content: "그건 사람마다 다르죠. 누군가는 조기졸업이란걸 합니다."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "a1", content: "대학은 인생을 더 여유롭게 살게 해줍니다. 가야됩니다."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "a2", content: "전 찬성입니다. 왜냐하면 대학교를 가야 시민으로서 성장할 수 있기 때문입니다."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "a2", content: "그리고 요즘엔 국가장학금도 잘 나옵니다."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "a2", content: "대학을 가는게 낫습니다."), side: .agree)
//        summaryManager.add(chat: Chat(userID: "b1", content: "반대입니다. 대학을 안가도 연애는 할 수 있어요."), side: .disagree)
//        summaryManager.add(chat: Chat(userID: "b1", content: "저는 대학을 졸업하려고 7년째 다니고 있습니다.그 시간에 일을 했으면 어땠을까요?"), side: .disagree)
//        summaryManager.add(chat: Chat(userID: "b1", content: "대학은 안기는데 낫습니다."), side: .disagree)
//        summaryManager.add(chat: Chat(userID: "b2", content: "대학을 가면 돈이 너무 많이 듭니다. 그 시간에 일을 시작하는게 낫습니다."), side: .disagree)
//        summaryManager.add(chat: Chat(userID: "b2", content: "대학교를 가보셨는지 모르겠는데 시간도 너무 많이 듭니다."), side: .disagree)
//        summaryManager.add(chat: Chat(userID: "b2", content: "대학교가는 돈을 아껴서 노는게 낫습니다."), side: .disagree)
//        print("시작!!!!!!!!!!!!!")
//        UserInfoManager.shared.userInfos["a1"] = UserInfo(uid: "a1", nickname: "찬성1")
//        UserInfoManager.shared.userInfos["a2"] = UserInfo(uid: "a2", nickname: "찬성2")
//        UserInfoManager.shared.userInfos["b1"] = UserInfo(uid: "b1", nickname: "반대1")
//        UserInfoManager.shared.userInfos["b2"] = UserInfo(uid: "b2", nickname: "반대2")
//        let group = DispatchGroup()
//        group.enter()
//        group.enter()
//        summaryManager.summariesForAgree(completion: { [unowned self] results in
//            results.forEach { uid, contents in
//                guard let nickname = UserInfoManager.shared.userInfos[uid]?.nickname
//                else { return }
//                print(Chat(userID: "bot", content: "찬성측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
//                print(Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
//            }
//            group.leave()
//        })
//        summaryManager.summariesForDisAgree(completion: { [unowned self] results in
//            results.forEach { uid, contents in
//                guard let nickname = UserInfoManager.shared.userInfos[uid]?.nickname
//                else { return }
//                print(Chat(userID: "bot", content: "반대측 \"\(nickname)\"님의 발언 요약입니다:", date: Date(), nickName: nil))
//                print(Chat(userID: "bot", content: contents, date: Date(), nickName: nil))
//            }
//            group.leave()
//        })
//        group.notify(queue: DispatchQueue.global(qos: .userInteractive)) { [unowned self] in
//            print("끝!!!!!!!!!!!!!!!!!!!!!!!")
//        }
//    }

}
