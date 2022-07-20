//
//  ActivityTracker.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/27.
//

import Foundation
import RxSwift
import RxCocoa

class ActivityTracker: SharedSequenceConvertibleType {

    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy

    // MARK: properties

    private let _lock = NSRecursiveLock()
    private let _behavior = BehaviorRelay<Bool>(value: false)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    // MARK: - init/deinit

    init() {
        _loading = _behavior.asDriver()
            .distinctUntilChanged()
    }
    
    // MARK: - methods

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }
    
    private func subscribed() {
        _lock.lock()
        _behavior.accept(true)
        _lock.unlock()
    }
    
    private func sendStopLoading() {
        _lock.lock()
        _behavior.accept(false)
        _lock.unlock()
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }

}

extension ObservableConvertibleType {

    func trackActivity(_ activityTracker: ActivityTracker) -> Observable<Element> {
        return activityTracker.trackActivityOfObservable(self)
    }

}
