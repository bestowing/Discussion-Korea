//
//  BaseViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

class BaseViewController: UIViewController {

    deinit {
        print("🗑", Self.description())
    }

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
    }

}
