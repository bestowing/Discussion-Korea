//
//  DefaultReportNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/11.
//

import UIKit

final class DefaultReportNavigator: BaseNavigator, ReportNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    // MARK: - init/deinit

    init(services: UsecaseProvider, navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    // MARK: - methods

    func toReport(_ userID: String, _ reportedUID: String) {
        let viewController = ReportViewController()
        viewController.viewModel = ReportViewModel(
            userID: userID,
            reportedUID: reportedUID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        self.navigationController.pushViewController(viewController, animated: true)
    }

    func toChatRoomSideMenu() {
        let alert = UIAlertController(title: "결과",
                                      message: "신고가 접수되었습니다.",
                                      preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.navigationController.popToRootViewController(animated: true)
        self.navigationController.topViewController?.present(alert, animated: true)
    }

    func toChatRoomCover() {
        let alert = UIAlertController(title: "결과",
                                      message: "신고가 접수되었습니다.",
                                      preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.navigationController.popToRootViewController(animated: true)
        self.navigationController.topViewController?.present(alert, animated: true)
    }

}
