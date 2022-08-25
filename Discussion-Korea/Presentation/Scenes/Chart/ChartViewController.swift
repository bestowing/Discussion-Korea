//
//  ChartViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/25.
//

import UIKit

final class ChartViewController: BaseViewController {

    // MARK: properties

    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .label
        button.accessibilityLabel = "닫기"
        return button
    }()

    // MARK: - methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "조직도"
        self.setSubViews()
    }

    private func setSubViews() {
        self.navigationItem.leftBarButtonItem = self.exitButton
    }

}
