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

    func toChatRoom(_ chatRoomID: String)
    func toSideMenu()
    func toNicknameAlert() -> Observable<String>
    func toSideAlert() -> Observable<Side>
    func toVoteAlert() -> Observable<Side>

}

final class DefaultChatRoomNavigator: ChatRoomNavigator {

    // MARK: - properties

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

    // MARK: - methods

    func toChatRoom(_ chatRoomID: String) {
        self.makeTransparentNavigationBar()
        let chatRoomViewController = ChatRoomViewController()
        let chatRoomViewModel = ChatRoomViewModel(
            chatRoomID: chatRoomID,
            chatsUsecase: self.services.makeChatsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            discussionUsecase: self.services.makeDiscussionUsecase(),
            navigator: self
        )
        chatRoomViewController.viewModel = chatRoomViewModel
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
        self.presentingViewController = chatRoomViewController
    }

    private func makeTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundEffect = UIBlurEffect.init(style: .systemMaterial)
        self.navigationController.navigationBar.standardAppearance = appearance
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

    func toSideAlert() -> Observable<Side> {
        return Observable.create { [unowned self] subscribe in
            let alert = UIAlertController(title: "토론 진영 설정",
                                          message: "토론이 예정되었습니다. 참여를 원하시면 진영을 선택해주세요.",
                                          preferredStyle: UIAlertController.Style.alert)
            let agreeAction = UIAlertAction(title: "찬성", style: .default) { _ in
                subscribe.onNext(.agree)
                subscribe.onCompleted()
            }
            let disagreeAction = UIAlertAction(title: "반대", style: .destructive) { _ in
                subscribe.onNext(.disagree)
                subscribe.onCompleted()
            }
            let judgeAction = UIAlertAction(title: "판정단", style: .default) { _ in
                subscribe.onNext(.judge)
                subscribe.onCompleted()
            }
            let observerAction = UIAlertAction(title: "구경꾼", style: .default) { _ in
                subscribe.onNext(.observer)
                subscribe.onCompleted()
            }
            alert.addAction(agreeAction)
            alert.addAction(disagreeAction)
            alert.addAction(judgeAction)
            alert.addAction(observerAction)
            self.presentingViewController?.present(alert, animated: true)
            return Disposables.create()
        }
    }

    func toVoteAlert() -> Observable<Side> {
        return Observable.create { [unowned self] subscribe in
            let alert = UIAlertController(title: "판정단 투표",
                                          message: "어느쪽이 더 잘했나요? 투표해주세요",
                                          preferredStyle: UIAlertController.Style.alert)
            let agreeAction = UIAlertAction(title: "찬성측", style: .default) { _ in
                subscribe.onNext(.agree)
                subscribe.onCompleted()
            }
            let disagreeAction = UIAlertAction(title: "반대측", style: .destructive) { _ in
                subscribe.onNext(.disagree)
                subscribe.onCompleted()
            }
            alert.addAction(agreeAction)
            alert.addAction(disagreeAction)
            self.presentingViewController?.present(alert, animated: true)
            return Disposables.create()
        }
    }

    private func toHome() {
        self.navigationController.popViewController(animated: true)
    }

}
