//
//  DefaultSettingNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import FirebaseAuth
import UIKit

final class DefaultSettingNavigator: BaseNavigator, SettingNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    // MARK: - methods

    func toSetting() {
        self.makeOpaqueNavigationBar()
        let settingViewController = SettingViewController()
        settingViewController.contents = ["오픈소스 라이선스 이용고지", "로그아웃", "탈퇴하기"]
        settingViewController.selected = [toOpenSource, toSignOut, toResign]
        settingViewController.title = "설정"
        self.navigationController.pushViewController(settingViewController, animated: true)
        self.presentingViewController = settingViewController
    }

    private func makeOpaqueNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        self.navigationController.navigationBar.standardAppearance = appearance
    }

    func toOpenSource() {
        let openSourceNavigator = DefaultOpenSourceNavigator(navigationController: self.navigationController)
        openSourceNavigator.toOpenSource()
    }

    func toSignOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.failureAlert(job: "로그아웃")
        }
    }

    func toResign() {
        guard let user = Auth.auth().currentUser
        else {
            self.failureAlert(job: "회원탈퇴")
            return
        }
        user.delete { error in
            if let _ = error {
                self.failureAlert(job: "회원탈퇴")
            }
        }
    }

    private func failureAlert(job: String) {
        guard let presentingViewController = presentingViewController
        else { return }
        let alert = UIAlertController(
            title: "오류!",
            message: "\(job)중에 오류가 발생했습니다. 잠시후에 재시도해주세요..",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        presentingViewController.present(alert, animated: true)
    }

}
