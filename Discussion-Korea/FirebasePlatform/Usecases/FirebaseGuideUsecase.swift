//
//  FirebaseGuideUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import Foundation
import RxSwift

final class FirebaseGuideUsecase: GuideUsecase {

    private let reference: GuideReference

    init(reference: GuideReference) {
        self.reference = reference
    }

    func guides() -> Observable<[Guide]> {
        return self.reference.guides()
    }

}
