//
//  IndependentBuilderUsecase.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/09.
//

import Foundation
import RxSwift

final class IndependentBuilderUsecase: BuilderUsecase {

    private let discussionBuilder: DiscussionBuilder

    init(discussionBuilder: DiscussionBuilder) {
        self.discussionBuilder = discussionBuilder
    }

    func setBasic(_ basic: (String, Date)) -> Observable<Void> {
        return self.discussionBuilder.setBasic(basic)
    }
    
    func setDetail(_ detail: (Int, Int, Int, Bool)) -> Observable<Void> {
        return self.discussionBuilder.setDetail(detail)
    }
    
    func getResult() -> Observable<Discussion?> {
        return self.discussionBuilder.getResult()
    }

}
