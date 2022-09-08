//
//  DiscussionReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseDatabase
import RxSwift

final class DiscussionReference {

    private let reference: DatabaseReference
    private let dateFormatter: DateFormatter

    init(reference: DatabaseReference, dateFormatter: DateFormatter) {
        self.reference = reference
        self.dateFormatter = dateFormatter
    }

    func getDiscussions(from roomID: String) -> Observable<Discussion> {
        return Observable<Discussion>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/discussions")
                .observe(.childAdded) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary,
                          let dateString = dic["date"] as? String,
                          let date = self.dateFormatter.date(from: dateString),
                          let durations = dic["durations"] as? [Int],
                          let topic = dic["topic"] as? String,
                          let isFulltime = dic["isFulltime"] as? Bool
                    else { return }
                    let discussion = Discussion(
                        uid: snapshot.key,
                        date: date,
                        durations: durations,
                        topic: topic,
                        isFulltime: isFulltime
                    )
                    subscribe.onNext(discussion)
                }
            return Disposables.create()
        }
    }

    func add(_ discussion: Discussion, to roomID: String) -> Observable<Void> {
        let value: [String: Any] = [
            "date": self.dateFormatter.string(from: discussion.date),
            "durations": discussion.durations,
            "topic": discussion.topic,
            "isFulltime": discussion.isFulltime
        ]
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/discussions")
                .childByAutoId()
                .setValue(value)
            subscribe.onNext(())
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func getPhase(of roomID: String) -> Observable<Int> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/phase").observe(.childAdded) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            self.reference.child("chatRoom/\(roomID)/phase").observe(.childChanged) { snapshot in
                guard let phase = snapshot.value as? Int
                else { return }
                subscribe.onNext(phase)
            }
            return Disposables.create()
        }
    }

    func date(of userID: String, in roomID: String) -> Observable<Date?> {
        return Observable.create { [unowned self] subscribe in
            subscribe.onNext(nil)
            self.reference.child("chatRoom/\(roomID)/speaker/\(userID)").observe(.childAdded) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = self.dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            self.reference.child("chatRoom/\(roomID)/speaker/\(userID)").observe(.childRemoved) { snapshot in
                subscribe.onNext(nil)
            }
            return Disposables.create()
        }
    }

    func getDiscussionTime(of roomID: String) -> Observable<Date> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/endDate").observe(.childAdded) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = self.dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            self.reference.child("chatRoom/\(roomID)/endDate").observe(.childChanged) { snapshot in
                guard let endDateString = snapshot.value as? String,
                      let endDate = self.dateFormatter.date(from: endDateString)
                else { return }
                subscribe.onNext(endDate)
            }
            return Disposables.create()
        }
    }

    func opinions(of roomID: String) -> Observable<(UInt, UInt)> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/supporters").observe(.value) { snapshot in
                guard let dictionary = snapshot.value as? NSDictionary
                else { return }
                let agree: UInt
                if let agrees = dictionary[Side.agree.rawValue] as? [String] {
                    agree = UInt(agrees.count)
                } else {
                    agree = 0
                }
                let disagree: UInt
                if let disagrees = dictionary[Side.disagree.rawValue] as? [String] {
                    disagree = UInt(disagrees.count)
                } else {
                    disagree = 0
                }
                subscribe.onNext((agree, disagree))
            }
            return Disposables.create()
        }
    }

    func discussionResult(userID: String, chatRoomID: String) -> Observable<DiscussionResult> {
        // 최근 결과 느낌으로 해야할듯
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(chatRoomID)/users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let resultString = dictionary["result"] as? String
                    else { return }
                    switch resultString {
                    case "win":
                        subscribe.onNext(.win)
                    case "draw":
                        subscribe.onNext(.draw)
                    case "lose":
                        subscribe.onNext(.lose)
                    default:
                        break
                    }
                    self.clearResult(userID: userID, chatRoomID: chatRoomID)
                }
            return Disposables.create()
        }
    }

    private func clearResult(userID: String, chatRoomID: String) {
        self.reference
            .child("chatRoom/\(chatRoomID)/users/\(userID)/result")
            .setValue(nil)
        return
    }

}
