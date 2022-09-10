//
//  SummaryManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/05/18.
//

import Alamofire
import Combine
import FirebaseDatabase
import Foundation

final class SummaryManager {

    private var agreeContents: [[String]]
    private var disagreeContents: [[String]]

    private var agreeIndexes: [String: Int]
    private var disagreeIndexes: [String: Int]

    private let dateFormatter: DateFormatter
    private let reference: DatabaseReference

    init(dateFormatter: DateFormatter,
         reference: DatabaseReference) {
        self.agreeContents = []
        self.disagreeContents = []
        self.agreeIndexes = [:]
        self.disagreeIndexes = [:]
        self.dateFormatter = dateFormatter
        self.reference = reference
    }

    func connect() -> AnyPublisher<String, Never> {
        let now = Date()
        let subject = PassthroughSubject<String, Never>()
        self.reference.observe(.childAdded) { [unowned self] snapshot in
            guard let dic = snapshot.value as? [String: Any],
                  let dateString = dic["date"] as? String,
                  let date = dateFormatter.date(from: dateString),
                  date > now,
                  let userID = dic["user"] as? String,
                  userID != "bot",
                  let content = dic["content"] as? String,
                  let sideString = dic["side"] as? String
            else { return }
            let uid = snapshot.key
            let chat = Chat(userID: userID, content: content)
            self.isDirty(chat: chat) { [unowned self] (dirty, comment) in
                if dirty == true,
                   let comment = comment {
                    self.masking(uid: uid, chat: chat)
                    subject.send(comment)
                } else {
                    self.add(chat: chat, side: Side.toSide(from: sideString))
                }
            }
        }
        return subject.eraseToAnyPublisher()
    }

    private func isDirty(chat: Chat, completion: @escaping (Bool, String?) -> Void) {
        let group = DispatchGroup()
        var vote = 0
        var toxic: Chat.Toxic? = nil
        let urlStrings = ["http://119.194.17.59:8080/predictions/classification1",
//                          "https://zw5k7gzpb5.execute-api.ap-northeast-2.amazonaws.com/dev/classification",
                          "http://119.194.17.59:8888/predictions/classification2",
                          "http://119.194.17.59:8080/predictions/classification3"]
        urlStrings.enumerated().forEach { [unowned self] (index, urlString) in
            print("enter")
            group.enter()
            var result: Bool
            if index == 2 {
                result = self.request(content: chat.content, to: urlString) { (response: AFDataResponse<Data?>) in
                    switch response.result {
                    case .success(let data):
                        if let data = data,
                           let successMessage = String(bytes: data, encoding: .utf8) {
                            toxic = Chat.Toxic.toToxic(from: successMessage)
                            if toxic != .clean {
                                print(index, "toxic으로 투표함")
                                vote += 1
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                    group.leave()
                }
            } else {
                result = self.request(content: chat.content, to: urlString) { (response: AFDataResponse<String>) in
                    switch response.result {
                    case .success(let resultString):
                        if resultString == "1" {
                            print(index, "toxic으로 투표함")
                            vote += 1
                        }
                    case .failure(let error):
                        print(error)
                    }
                    group.leave()
                }
            }
            if !result {
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
            completion(vote > 1, toxic?.rawValue)
        }
    }

    private func request(content: String, to urlString: String,
                         completionHandler: @escaping (AFDataResponse<String>) -> Void) -> Bool {
        guard let url = URL(string: urlString)
        else {
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = ["text": content] as Dictionary
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            AF.request(request).responseString(completionHandler: completionHandler)
            return true
        } catch {
            print(error)
            return false
        }
    }

    private func request(content: String, to urlString: String,
                         completionHandler: @escaping (AFDataResponse<Data?>) -> Void) -> Bool {
        guard let url = URL(string: urlString)
        else {
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = ["text": content] as Dictionary
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            AF.request(request).response(completionHandler: completionHandler)
            return true
        } catch {
            print(error)
            return false
        }
    }

    private func masking(uid: String, chat: Chat) {
        let values: [String: Any] = ["toxic": true]
        self.reference.child(uid)
            .updateChildValues(values)
    }

    func add(chat: Chat, side: Side) {
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

//    func summariesForAgree(completion: @escaping ([(String, String)]) -> Void) {
//        let agreeResults: [(String, String)] = self.agreeIndexes.map { [unowned self] (uid, index) in
//            return (uid, self.agreeContents[index].joined(separator: " "))
//        }
//        self.resetAgree()
//        DispatchQueue.global(qos: .userInteractive).async {
//            let group = DispatchGroup()
//            var agreeSummaries = Array(repeating: "", count: agreeResults.count)
//            agreeResults.enumerated().forEach { (index, result) in
//                group.enter()
//                print("찬성측의 ", result.1, "를 요약하려고 함")
//                let urlString = "http://115.145.172.80:8080/predictions/summarization"
//                var request = URLRequest(url: URL(string: urlString)!)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                let params = ["text": result.1] as Dictionary
//                do {
//                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
//                    AF.request(request).response { response in
//                        switch response.result {
//                        case .success(let data):
//                            if let data = data,
//                               let successMessage = String(bytes: data, encoding: .utf8) {
//                                agreeSummaries[index] = successMessage
//                            } else {
//                                agreeSummaries[index] = "요약에 실패했습니다."
//                            }
//                        case .failure(let error):
//                            agreeSummaries[index] = "요약에 실패했습니다."
//                            print(error)
//                        }
//                        group.leave()
//                    }
//                } catch {
//                    print(error)
//                    agreeSummaries[index] = "요약에 실패했습니다."
//                    group.leave()
//                }
//            }
//            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
//                let result = zip(agreeResults, agreeSummaries).map { (args, summary) -> (String, String) in
//                    return (args.0, summary)
//                }
//                completion(result)
//            }
//        }
//    }

    func summaries(completion: @escaping ([(Side, String, String)]) -> Void) {
        let results: [(Side, String, String)] = (self.agreeIndexes.map { [unowned self] (uid, index) in
            return (Side.agree, uid, self.agreeContents[index].joined(separator: " "))
        }) + (self.disagreeIndexes.map { [unowned self] (uid, index) in
            return (Side.disagree, uid, self.disagreeContents[index].joined(separator: " "))
        })
        self.resetAgree()
        self.resetDisagree()
        DispatchQueue.global(qos: .userInteractive).async {
            let group = DispatchGroup()
            var summaries = Array(repeating: "", count: results.count)
            results.enumerated().forEach { (index, result) in
                group.enter()
                print("\(result.0.rawValue)측의 ", result.1, "를 요약하려고 함")
                let urlString = "http://115.145.172.80:8080/predictions/summarization"
                var request = URLRequest(url: URL(string: urlString)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let params = ["text": result.2] as Dictionary
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                    AF.request(request).response { response in
                        switch response.result {
                        case .success(let data):
                            if let data = data,
                               let successMessage = String(bytes: data, encoding: .utf8) {
                                summaries[index] = successMessage
                            } else {
                                summaries[index] = "요약에 실패했습니다."
                            }
                        case .failure(let error):
                            summaries[index] = "요약에 실패했습니다."
                            print(error)
                        }
                        group.leave()
                    }
                } catch {
                    print(error)
                    summaries[index] = "요약에 실패했습니다."
                    group.leave()
                }
            }
            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
                let result = zip(results, summaries).map { (args, summary) -> (Side, String, String) in
                    return (args.0, args.1, summary)
                }
                completion(result)
            }
        }
    }

//    func summariesForDisAgree(completion: @escaping ([(String, String)]) -> Void) {
//        let disagreeResults: [(String, String)] = self.disagreeIndexes.map { [unowned self] (uid, index) in
//            return (uid, self.disagreeContents[index].joined(separator: " "))
//        }
//        self.resetDisagree()
//        DispatchQueue.global(qos: .userInteractive).async {
//            let group = DispatchGroup()
//            var disagreeSummaries = Array(repeating: "", count: disagreeResults.count)
//            disagreeResults.enumerated().forEach { (index, result) in
//                group.enter()
//                print("반대측의 ", result.1, "를 요약하려고 함")
//                let urlString = "http://115.145.172.80:8080/predictions/summarization"
//                var request = URLRequest(url: URL(string: urlString)!)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                let params = ["text": result.1] as Dictionary
//                do {
//                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
//                    AF.request(request).response { response in
//                        switch response.result {
//                        case .success(let data):
//                            if let data = data,
//                               let successMessage = String(bytes: data, encoding: .utf8) {
//                                disagreeSummaries[index] = successMessage
//                            } else {
//                                disagreeSummaries[index] = "요약에 실패했습니다."
//                            }
//                        case .failure(let error):
//                            disagreeSummaries[index] = "요약에 실패했습니다."
//                            print(error)
//                        }
//                        group.leave()
//                    }
//                } catch {
//                    print(error)
//                    disagreeSummaries[index] = "요약에 실패했습니다."
//                    group.leave()
//                }
//            }
//            group.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
//                let result = zip(disagreeResults, disagreeSummaries).map { (args, summary) -> (String, String) in
//                    return (args.0, summary)
//                }
//                completion(result)
//            }
//        }
//    }

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
