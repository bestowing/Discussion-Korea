//
//  SummaryManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/18.
//

import Alamofire
import FirebaseDatabase
import Foundation

final class SummaryManager {

    private var agreeContents: [[String]]
    private var disagreeContents: [[String]]

    private var agreeIndexes: [String: Int]
    private var disagreeIndexes: [String: Int]

    private let dateFormatter: DateFormatter

    init(dateFormatter: DateFormatter) {
        self.agreeContents = []
        self.disagreeContents = []
        self.agreeIndexes = [:]
        self.disagreeIndexes = [:]
        self.dateFormatter = dateFormatter
    }

    func connect(reference: DatabaseReference) {
        let now = Date()
        reference.observe(.childAdded) { [unowned self] snapshot in
            guard let dic = snapshot.value as? [String: Any],
                  let dateString = dic["date"] as? String,
                  let date = dateFormatter.date(from: dateString),
                  date > now,
                  let userID = dic["user"] as? String,
                  let content = dic["content"] as? String,
                  let sideString = dic["side"] as? String
            else { return }
            let chat = Chat(userID: userID, content: content)
            self.add(chat: chat, side: Side.toSide(from: sideString))
        }
    }

    private func add(chat: Chat, side: Side) {
        guard side == .agree || side == .disagree
        else { return }
        let uid = chat.userID
        self.register(uid: uid, side: side)
        let content = chat.content
        if side == .agree {
            let index = self.agreeIndexes[uid]!
            self.agreeContents[index].append(content)
            print("찬성측에 ", chat, "이 추가되었어요")
        } else {
            let index = self.disagreeIndexes[uid]!
            self.disagreeContents[index].append(content)
            print("반대측에 ", chat, "이 추가되었어요")
        }
    }

    func summariesForAgree(completion: @escaping ([String]) -> Void) {
        let agreeResult = self.agreeContents.map { $0.joined(separator: " ") }
        self.resetAgree()
        let queue = DispatchQueue.global(qos: .userInteractive)
        let group = DispatchGroup()
        queue.async {
            var agreeSummaries = Array(repeating: "", count: agreeResult.count)
            agreeResult.enumerated().forEach { (index, result) in
                group.enter()
                print("찬성측의 ", result, "를 요약하려고 함")
                let urlString = "http://119.194.17.59:8080/predictions/summarization"
                var request = URLRequest(url: URL(string: urlString)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let params = ["text": result] as Dictionary
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                    AF.request(request).response { response in
                        switch response.result {
                        case .success(let data):
                            if let data = data,
                               let successMessage = String(bytes: data, encoding: .utf8) {
                                agreeSummaries[index] = successMessage
                            } else {
                                agreeSummaries[index] = "요약에 실패했습니다."
                            }
                        case .failure(let error):
                            agreeSummaries[index] = "요약에 실패했습니다."
                            print(error)
                        }
                        group.leave()
                    }
                } catch {
                    print(error)
                    agreeSummaries[index] = "요약에 실패했습니다."
                    group.leave()
                }
                group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
                    completion(agreeSummaries)
                }
            }
        }
    }

    func summariesForDisAgree(completion: @escaping ([String]) -> Void) {
        let disagreeResult = self.disagreeContents.map { $0.joined(separator: " ") }
        self.resetDisagree()
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            var disagreeSummaries = Array(repeating: "", count: disagreeResult.count)
            let group = DispatchGroup()
            disagreeResult.enumerated().forEach { (index, result) in
                group.enter()
                print("반대측의 ", result, "를 요약하려고 함")
                let urlString = "http://119.194.17.59:8080/predictions/summarization"
                var request = URLRequest(url: URL(string: urlString)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let params = ["text": result] as Dictionary
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                    AF.request(request).response { response in
                        switch response.result {
                        case .success(let data):
                            if let data = data,
                               let successMessage = String(bytes: data, encoding: .utf8) {
                                disagreeSummaries[index] = successMessage
                            } else {
                                disagreeSummaries[index] = "요약에 실패했습니다."
                            }
                        case .failure(let error):
                            disagreeSummaries[index] = "요약에 실패했습니다."
                            print(error)
                        }
                        group.leave()
                    }
                } catch {
                    print(error)
                    disagreeSummaries[index] = "요약에 실패했습니다."
                    group.leave()
                }
                group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
                    completion(disagreeSummaries)
                }
            }
        }
    }

    /// 먼저 사용자를 등록해야함
    private func register(uid: String, side: Side) {
        // TODO: 이게 동시에 호출될 가능성이 없는지 확인해야함!! 만약 동시에 호출될 수 있으면 stream으로 바꿔주거나 동일 쓰레드에서만 실행되도록 하거나 lock을 써서 동기화해줘야함
        if side == .agree {
            if self.agreeIndexes[uid] == nil {
                self.agreeIndexes[uid] = self.agreeContents.count
                self.agreeContents.append([])
            }
        } else {
            if self.disagreeIndexes[uid] == nil {
                self.disagreeIndexes[uid] = self.disagreeContents.count
                self.disagreeContents.append([])
            }
        }
    }

    private func resetAgree() {
        self.agreeContents = []
        self.agreeIndexes = [:]
    }

    private func resetDisagree() {
        self.disagreeContents = []
        self.disagreeIndexes = [:]
    }

}
