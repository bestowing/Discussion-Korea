//
//  ChatRoomsReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseDatabase
import FirebaseStorage
import RxSwift

final class ChatRoomsReference {

    private let reference: DatabaseReference
    private let storageReference: StorageReference

    init(reference: DatabaseReference,
         storageReference: StorageReference) {
        self.reference = reference
        self.storageReference = storageReference
    }

    func chatRooms() -> Observable<ChatRoom> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRooms")
                .observe(.childAdded) { snapshot in
                    guard let chatRoom = ChatRoom.toChatRoom(from: snapshot)
                    else { return }
                    subscribe.onNext(chatRoom)
            }
            return Disposables.create()
        }
    }

    func add(chatRoom: ChatRoom) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            guard let key = self.reference
                .child("chatRooms")
                .childByAutoId().key
            else {
                subscribe.onError(RefereceError.keyError)
                return Disposables.create()
            }
            var values: [String: Any] = ["title": chatRoom.title, "adminUID": chatRoom.adminUID]
            let userValue: [String: Any] = ["position": "admin"]
            if let profileURL = chatRoom.profileURL {
                let ref = self.storageReference
                    .child("\(chatRoom.uid)/profile/\(profileURL.lastPathComponent)")
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
                        let childUpdates: [String: Any] = [
                            "/chatRooms/\(key)": values,
                            "/chatRoom/\(key)/users/\(chatRoom.adminUID)": userValue,
                            "/chatRoom/\(key)/phase/value": 0
                        ]
                        self.reference.updateChildValues(childUpdates)
                        subscribe.onNext(())
                        subscribe.onCompleted()
                    }
                }
            } else {
                let childUpdates: [String: Any] = [
                    "/chatRooms/\(key)": values,
                    "/chatRoom/\(key)/users/\(chatRoom.adminUID)": userValue,
                    "/chatRoom/\(key)/phase/value": 0
                ]
                self.reference.updateChildValues(childUpdates)
                subscribe.onNext(())
                subscribe.onCompleted()
            }
            return Disposables.create()
        }
    }

    func latestChat(chatRoomID: String) -> Observable<Chat> {
        return Observable.create { [unowned self] subscribe in
            var lastChat: Chat?
            self.reference
                .child("chatRoom/\(chatRoomID)/messages")
                .queryLimited(toLast: 1)
                .observeSingleEvent(of: .value) { snapshot in
                    if let chat = snapshot.children.compactMap({ child -> Chat? in
                        guard let snapshot = child as? DataSnapshot
                        else { return nil }
                        return Chat.toChat(from: snapshot)
                    }).first {
                        subscribe.onNext(chat)
                        lastChat = chat
                    }
                    if let afterUID = lastChat?.uid {
                        self.reference
                            .child("chatRoom/\(chatRoomID)/messages")
                            .queryOrderedByKey()
                            .queryStarting(afterValue: afterUID)
                            .observe(.childAdded) { snapshot in
                                guard let chat = Chat.toChat(from: snapshot)
                                else { return }
                                subscribe.onNext(chat)
                            }
                    } else {
                        self.reference
                            .child("chatRoom/\(chatRoomID)/messages")
                            .observe(.childAdded) { snapshot in
                                guard let chat = Chat.toChat(from: snapshot)
                                else { return }
                                subscribe.onNext(chat)
                            }
                    }
                }
            return Disposables.create()
        }
    }

    func numberOfUsers(chatRoomID: String) -> Observable<UInt> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(chatRoomID)/users")
                .observe(.value) { snapshot in
                    subscribe.onNext(snapshot.childrenCount)
                }
            return Disposables.create()
        }
    }

    func isFirstEntering(userID: String, chatRoomID: String) -> Observable<Bool> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("chatRoom/\(chatRoomID)/users")
                .observe(.value) { snapshot in
                    subscribe.onNext(!snapshot.hasChild("\(userID)"))
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

}
