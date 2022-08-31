//
//  FirebaseLawUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import Foundation
import RxSwift

final class FirebaseLawUsecase: LawUsecase {

    private let reference: LawReference

    init(reference: LawReference) {
        self.reference = reference
    }

    func laws() -> Observable<[String]> {
        // FIXME: 테스트용임
        return Observable.create { o in
            o.onNext([
                "방구석 대한민국은 자유민주주의의 토론 문화에 기반한 정치 씽크탱크이다.",
                "관료의 임명은 공석을 자유롭게 선점하여 셀프로 한다.",
                "방구석 대한민국 관료의 임기는 무기한 유지된다.",
                "헌법개정은 재적위원 과반수의 발의로 제안되어야 한다. 단, 헌법개정안 발의는 50명 이상의 재적위원이 존재할 때 가능하다.",
                "방구석회의는 헌법개정안이 공고된 날로부터 7일 이내에 의결하여야 하며, 재적위원 3분의 2 이상의 찬성을 얻어야 한다.",
                "토론의 주제는 1인의 발제에 따라 정해지며, 정책 및 정치 현안 등 자유 주제이다.",
                "투표의 기간은 발제 후 1일 ~ 7일 기간 중으로 발제자가 지정할 수 있다.",
                "치열하게 토론하되, 비방성 글 혹은 광고 등은 사회자 재량으로 강퇴한다."
            ])
            o.onCompleted()
            return Disposables.create()
        }
    }

}
