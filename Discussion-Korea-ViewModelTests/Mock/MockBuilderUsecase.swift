//
//  MockBuilderUsecase.swift
//  Discussion-Korea-ViewModelTests
//
//  Created by 이청수 on 2022/09/09.
//

import Foundation
import RxSwift

final class MockBuilderUsecase: BuilderUsecase {

    // MARK: - properties

    var setBasicStream: Observable<Void>
    var setDetailStream: Observable<Void>
    var getResultStream: Observable<Discussion?>

    // MARK: - init/deinit

    init() {
        self.setBasicStream = PublishSubject<Void>.init()
        self.setDetailStream = PublishSubject<Void>.init()
        self.getResultStream = PublishSubject<Discussion?>.init()
    }

    // MARK: - methods

    func setBasic(_ basic: (String, Date)) -> Observable<Void> {
        return self.setBasicStream
    }
    
    func setDetail(_ detail: (Int, Int, Int, Bool)) -> Observable<Void> {
        return self.setDetailStream
    }
    
    func getResult() -> Observable<Discussion?> {
        return self.getResultStream
    }
}
