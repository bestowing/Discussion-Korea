//
//  BaseViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit
import RxCocoa
import RxSwift

/// View Controller에서 반복되는 코드를 줄이기 위한 클래스
class BaseViewController: UIViewController {

    deinit {
        print("🗑", Self.description())
    }

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
    }

}

extension Reactive where Base: BaseViewController {

    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }

}
