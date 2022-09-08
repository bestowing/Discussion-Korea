//
//  DiscussionBuilder.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import Foundation
import RxSwift

final class DiscussionBuilder {

    private var basicInfo: (topic: String, startDate: Date)?
    private var detailInfo: (intro: Int, main: Int, conclusion: Int, fulltime: Bool)?

    deinit {
        print("🗑", self)
    }

    func setBasic(_ basic: (String, Date)) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.basicInfo = basic
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func setDetail(_ detail: (Int, Int, Int, Bool)) -> Observable<Void> {
        return Observable.create { [unowned self] subscribe in
            self.detailInfo = detail
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

    func getResult() -> Observable<Discussion?> {
        return Observable.create { [unowned self] subscribe in
            guard let basicInfo = basicInfo,
                  let detailInfo = detailInfo
            else {
                subscribe.onNext(nil)
                subscribe.onCompleted()
                return Disposables.create()
            }
            let discussion = Discussion(
                date: basicInfo.startDate,
                durations: [detailInfo.intro, detailInfo.main, detailInfo.conclusion],
                topic: basicInfo.topic,
                isFulltime: detailInfo.fulltime
            )
            subscribe.onNext(discussion)
            subscribe.onCompleted()
            return Disposables.create()
        }
    }

}
