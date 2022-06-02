//
//  OpenSourceNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/21.
//

import UIKit

protocol OpenSourceNavigator {

    func toOpenSource()

}

final class DefaultOpenSourceNavigator: OpenSourceNavigator {

    // MARK: properties

    private let navigationController: UINavigationController

    // MARK: - init/deinit

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toOpenSource() {
        let openSourceViewController = SettingViewController()
        openSourceViewController.contents = [
            "Firebase", "Kingfisher", "RxKeyboard", "RxSwift", "SideMenu", "SnapKit"
        ]
        openSourceViewController.selected = [toFirebase, toKingfisher, toRxKeyboard, toRxSwift, toSideMenu, toSnapKit]
        self.navigationController.pushViewController(openSourceViewController, animated: true)
    }

    private func toFirebase() {
        self.openURL(with: "https://github.com/firebase/firebase-ios-sdk/blob/master/LICENSE")
    }

    private func toKingfisher() {
        self.openURL(with: "https://github.com/onevcat/Kingfisher/blob/master/LICENSE")
    }

    private func toRxKeyboard() {
        self.openURL(with: "https://github.com/RxSwiftCommunity/RxKeyboard/blob/master/LICENSE")
    }

    private func toRxSwift() {
        self.openURL(with: "https://github.com/ReactiveX/RxSwift/blob/main/LICENSE.md")
    }

    private func toSideMenu() {
        self.openURL(with: "https://github.com/jonkykong/SideMenu/blob/master/LICENSE")
    }

    private func toSnapKit() {
        self.openURL(with: "https://github.com/SnapKit/SnapKit/blob/develop/LICENSE")
    }

    private func openURL(with urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }

}
