//
//  GuideReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseDatabase
import RxSwift

final class GuideReference {

    private let reference: DatabaseReference

    init(reference: DatabaseReference) {
        self.reference = reference
    }

    deinit {
        print("🗑", self)
    }

    func guides() -> Observable<[Guide]> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("guides")
                .observeSingleEvent(of: .value) { snapshot in
                    guard let array = snapshot.value as? NSArray
                    else {
                        subscribe.onError(RefereceError.guideError)
                        return
                    }
                    let guides: [Guide] = array.compactMap {
                        guard let dictionary = $0 as? NSDictionary,
                              let title = dictionary["title"] as? String,
                              let content = dictionary["content"] as? String
                        else { return nil }
                        return Guide(title: title, content: content)
                    }
                    subscribe.onNext(guides)
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

}
