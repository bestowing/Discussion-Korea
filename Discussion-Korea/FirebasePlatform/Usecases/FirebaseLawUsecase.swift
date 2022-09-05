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

    func laws() -> Observable<Laws> {
        self.reference.laws()
    }

}
