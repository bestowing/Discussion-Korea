//
//  FirebaseGuideUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import Foundation
import RxSwift

final class FirebaseGuideUsecase: GuideUsecase {

    private let reference: Reference

    init(reference: Reference) {
        self.reference = reference
    }

    func guides() -> Observable<[Guide]> {
        // FIXME: 테스트용임
        return Observable.create { o in
            o.onNext([
                Guide(
                    title: "방구석 대한민국은?",
                    content: "방구석 대한민국은 직접민주주의 시민참여 정치플랫폼으로서, 일반시민들의 의견을 모아 구성된 메타버스 가상정부 입니다."
                ),
                Guide(
                    title: "방구석 대한민국의 슬로건",
                    content: "시민으로부터 나온 권력을 다시 시민에게로"
                ),
                Guide(
                    title: "방구석 대한민국의 룰",
                    content: "방구석 대한민국 플랫폼내에서는 자유로운 의사표명 및 토론을 하실 수 있습니다. 단, 방구석 헌법에 저촉되는 행위시 이용에 제약을 받으실 수 있습니다"
                )
            ])
            o.onCompleted()
            return Disposables.create()
        }
    }

}
