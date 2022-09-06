//
//  UserInfoReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RxSwift

final class UserInfoReference {

    private let reference: DatabaseReference
    private let storageReference: StorageReference
    private let dateFormatter: DateFormatter

    init(reference: DatabaseReference,
         storageReference: StorageReference,
         dateFormatter: DateFormatter) {
        self.reference = reference
        self.storageReference = storageReference
        self.dateFormatter = dateFormatter
    }

    /// 회원 등록
    func register(
        userInfo: (email: String, password: String)
    ) -> Observable<Void> {
        return Observable.create { subscribe in
            Auth.auth()
                .createUser(withEmail: userInfo.email, password: userInfo.password) { authResult, error in
                    guard let _ = authResult,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.signUpError)
                        return
                    }
                    subscribe.onNext(())
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    /// userID로 UserInfo 요청
    func userInfo(with userID: String) -> Observable<UserInfo?> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let nickname = dictionary["nickname"] as? String,
                          let registerString = dictionary["registerAt"] as? String,
                          let registerAt = self.dateFormatter.date(from: registerString)
                    else {
                        subscribe.onNext(nil)
                        return
                    }
                    var userInfo = UserInfo(uid: userID, nickname: nickname, registerAt: registerAt)
                    if let urlString = dictionary["profile"] as? String,
                       let url = URL(string: urlString) {
                        userInfo.profileURL = url
                    }
                    if let win = dictionary["win"] as? Int {
                        userInfo.win = win
                    }
                    if let draw = dictionary["draw"] as? Int {
                        userInfo.draw = draw
                    }
                    if let lose = dictionary["lose"] as? Int {
                        userInfo.lose = lose
                    }
                    subscribe.onNext(userInfo)
                }
            return Disposables.create()
        }
    }

    /// roomID 방에 참가한 모든 사용자의 UserInfo를 반환함
    func userInfos(in roomID: String) -> Observable<[String: UserInfo]> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/users")
                .observe(.value) { snapshot in
                    guard let dic = snapshot.value as? NSDictionary
                    else { return }
                    subscribe.onNext(dic.compactMap { (key, value) in
                        guard let uid = key as? String
                        else { return nil }
                        let position: String? = (value as? NSDictionary)?["position"] as? String
                        return (uid: uid, position: position)
                    })
                }
            return Disposables.create()
        }.flatMap { [unowned self] userInfos in
            self.details(userInfos: userInfos)
        }
    }

    private func details(userInfos: [(uid: String, position: String?)]) -> Observable<[String: UserInfo]> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("users")
                .observeSingleEvent(of: .value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary
                    else {
                        subscribe.onError(RefereceError.userInfoError)
                        return
                    }
                    var userInfoDictionary = [String: UserInfo]()
                    for userInfo in userInfos {
                        guard let dic = dictionary[userInfo.uid] as? NSDictionary,
                              let nickname = dic["nickname"] as? String,
                              let registerString = dic["registerAt"] as? String,
                              let registerAt = self.dateFormatter.date(from: registerString)
                        else {
                            subscribe.onError(RefereceError.userInfoError)
                            return
                        }
                        let position = userInfo.position
                        var userInfo = UserInfo(uid: userInfo.uid, nickname: nickname, registerAt: registerAt)
                        userInfo.position = position
                        if let profile = dic["profile"] as? String,
                           let url = URL(string: profile) {
                            userInfo.profileURL = url
                        }
                        if let win = dic["win"] as? Int {
                            userInfo.win = win
                        }
                        if let draw = dic["draw"] as? Int {
                            userInfo.draw = draw
                        }
                        if let lose = dic["lose"] as? Int {
                            userInfo.lose = lose
                        }
                        userInfoDictionary[userInfo.uid] = userInfo
                    }
                    subscribe.onNext(userInfoDictionary)
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

    /// roomID 방에 userID 사용자를 추가함
    func add(userID: String, in roomID: String) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            let values: [String: Any] = ["position": "participant"]
            self.reference
                .child("chatRoom/\(roomID)/users")
                .child(userID)
                .setValue(values)
            subscribe.onNext(())
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    /// uid 사용자의 닉네임과 프로필 사진을 등록함
    func add(userInfo: (uid: String, nickname: String, profileURL: URL?)) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            var values: [String: Any] = [
                "nickname": userInfo.nickname,
                "registerAt": self.dateFormatter.string(from: Date()),
                "win": 0,
                "draw": 0,
                "lose": 0
            ]
            if let profileURL = userInfo.profileURL {
                let ref = self.storageReference
                    .child("\(userInfo.uid)/profile/\(profileURL.lastPathComponent)")
                ref.putFile(from: profileURL, metadata: nil) { metadata, error in
                    guard let _ = metadata,
                          error == nil
                    else {
                        subscribe.onError(RefereceError.profileError)
                        return
                    }
                    ref.downloadURL() { url, error in
                        guard let url = url,
                              error == nil
                        else {
                            subscribe.onError(RefereceError.profileError)
                            return
                        }
                        values["profile"] = url.absoluteString
                        self.reference.child("users/\(userInfo.uid)")
                            .setValue(values)
                        subscribe.onNext(())
                        subscribe.onCompleted()
                    }
                }
            } else {
                self.reference.child("users/\(userInfo.uid)")
                    .setValue(values)
                subscribe.onNext(())
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
    }

}

// MARK: - side

extension UserInfoReference {

    /// roomID 방에 userID 사용자의 side를 설정함
    func add(side: Side, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/sides/\(side.rawValue)")
                .updateChildValues([userID: true])
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)")
                .updateChildValues(["side": side.rawValue])
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    /// roomID 방에 userID 사용자의 side를 업데이트함
    func update(side: Side?, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)/side")
                .setValue(side)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    /// roomID 방에서 userID 사용자의 Optional side를 반환함
    func userInfo(in roomID: String, with userID: String) -> Observable<Side?> {
        return Observable.create { [unowned self] subscribe in
            self.reference
                .child("chatRoom/\(roomID)/users/\(userID)")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let sideString = dictionary["side"] as? String
                    else {
                        subscribe.onNext(nil)
                        return
                    }
                    subscribe.onNext(Side.toSide(from: sideString))
                }
            return Disposables.create()
        }
    }

    /// roomID 방에서 userID 사용자가 side로 투표함
    func vote(side: Side, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/votes/\(side.rawValue)").runTransactionBlock { currentData in
                if var votes = currentData.value as? [AnyObject] {
                    votes.append(userID as AnyObject)
                    currentData.value = votes
                } else {
                    currentData.value = [userID]
                }
                return TransactionResult.success(withValue: currentData)
            }
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

}

// MARK: - 지지 표명

extension UserInfoReference {

    func support(side: Side, in roomID: String, with userID: String) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(roomID)/supporters").runTransactionBlock { currentData in
                if let supporters = currentData.value as? [String: AnyObject] {
                    var newSupporters: [String: AnyObject] = supporters
                    let sides = [Side.agree, Side.disagree, Side.judge]
                    sides.forEach {
                        if $0 == side {
                            if var supporter = supporters[$0.rawValue] as? [String] {
                                guard !supporter.contains(userID) else { return }
                                supporter.append(userID)
                                newSupporters[$0.rawValue] = supporter as AnyObject
                            } else {
                                newSupporters[$0.rawValue] = [userID] as AnyObject
                            }
                        } else {
                            guard var supporter = supporters[$0.rawValue] as? [String],
                                  let index = supporter.firstIndex(of: userID) else { return }
                            supporter.remove(at: index)
                            newSupporters[$0.rawValue] = supporter as AnyObject
                        }
                    }
                    currentData.value = newSupporters
                } else {
                    currentData.value = [side.rawValue: [userID]]
                }
                subscribe.onCompleted()
                return TransactionResult.success(withValue: currentData)
            }
            return Disposables.create()
        }
    }

    func supporters(in roomID: String) -> Observable<(String, Side)> {
        return Observable.create { [unowned self] subscribe in
            let sides = [Side.agree, .disagree, .judge]
            sides.forEach { side in
                self.reference.child("chatRoom/\(roomID)/supporters/\(side.rawValue)").observe(.childAdded) { snapshot in
                    guard let userID = snapshot.value as? String else { return }
                    subscribe.onNext((userID, side))
                }
            }
            return Disposables.create()
        }
    }

}
