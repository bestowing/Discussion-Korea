//
//  LawReference.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import FirebaseDatabase
import RxSwift

final class LawReference {

    private let reference: DatabaseReference
    private let dateFormatter: DateFormatter

    init(reference: DatabaseReference, dateFormatter: DateFormatter) {
        self.reference = reference
        self.dateFormatter = dateFormatter
    }

    deinit {
        print("🗑", self)
    }

    func laws() -> Observable<Laws> {
        return Observable.create { [unowned self] subscribe in
            self.reference.child("laws")
                .observe(.value) { snapshot in
                    guard let dictionary = snapshot.value as? NSDictionary,
                          let lastUpdatedString = dictionary["lastUpdated"] as? String,
                          let lastUpdated = self.dateFormatter.date(from: lastUpdatedString),
                          let items = dictionary["items"] as? NSArray
                    else {
                        subscribe.onError(RefereceError.lawError)
                        return
                    }
                    var lawArray = [Law]()
                    for (index, item) in items.enumerated() {
                        guard let dictionary = item as? NSDictionary,
                              let topic = dictionary["topic"] as? String,
                              let contents = dictionary["contents"] as? String
                        else {
                            subscribe.onError(RefereceError.lawError)
                            return
                        }
                        lawArray.append(
                            Law(article: index + 1, topic: topic, contents: contents)
                        )
                    }
                    subscribe.onNext(
                        Laws(
                            lastUpdated: lastUpdated,
                            laws: lawArray
                        )
                    )
                    subscribe.onCompleted()
                }
            return Disposables.create()
        }
    }

}
