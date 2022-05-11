//
//  ChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SideMenu
import UIKit
import RxSwift

protocol ChatRoomNavigator {

    func toChatRoom()
    func toSideMenu()
    func toNicknameAlert() -> Observable<String>

}

final class DefaultChatRoomNavigator: ChatRoomNavigator {

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    deinit {
        print(#function, self)
    }

    func toChatRoom() {
        let chatRoomViewController = ChatRoomViewController()
        let chatRoomViewModel = ChatRoomViewModel(
            chatsUsecase: self.services.makeChatsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            navigator: self
        )
        chatRoomViewController.viewModel = chatRoomViewModel
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
        self.presentingViewController = chatRoomViewController
    }

    func toSideMenu() {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultChatRoomSideMenuNavigator(
            services: self.services,
            presentedViewController: presentingViewController
        )
        navigator.toChatRoomSideMenu()
    }

    func toNicknameAlert() -> Observable<String> {
        return Observable.create { [unowned self] subscribe in
            let alert = UIAlertController(title: "닉네임 설정",
                                          message: "채팅방에 처음으로 입장할때 닉네임을 설정해야 합니다.",
                                          preferredStyle: UIAlertController.Style.alert)
            let exitAction = UIAlertAction(title: "나가기", style: .cancel) {_ in
                subscribe.onCompleted()
                self.toHome()
            }
            let registAction = UIAlertAction(title: "등록", style: .default) {_ in
                guard let nickname = alert.textFields?.first?.text
                else { return }
                subscribe.onNext(nickname)
                subscribe.onCompleted()
//                self.repository.setInfo(name: nickname)
            }
            registAction.isEnabled = false
            alert.addTextField(configurationHandler: { textField in
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: textField, queue: OperationQueue.main, using: { _ in
                    registAction.isEnabled = !(textField.text?.isEmpty ?? true)
                })
                textField.placeholder = "닉네임을 입력해주세요"
            })
            alert.addAction(exitAction)
            alert.addAction(registAction)
            self.presentingViewController?.present(alert, animated: true)
            return Disposables.create()
        }
    }

    private func toHome() {
        self.navigationController.popViewController(animated: true)
    }

}
