//
//  ChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import SideMenu
import UIKit
import RxSwift

enum DiscussionResult {
    case win
    case draw
    case lose
}

protocol ChatRoomNavigator {

    func toChatRoom(_ uid: String, _ chatRoom: ChatRoom)
    func toSideMenu(_ chatRoom: ChatRoom)
    func toEnterAlert() -> Observable<Bool>
    func toSideAlert() -> Observable<Side>
    func toVoteAlert() -> Observable<Side>
    func toDiscussionResultAlert(result: DiscussionResult)
    func appear()
    func disappear()

}

final class DefaultChatRoomNavigator: ChatRoomNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let navigationController: UINavigationController

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toChatRoom(_ uid: String, _ chatRoom: ChatRoom) {
        self.makeTransparentNavigationBar()
        let chatRoomViewController = ChatRoomViewController()
        chatRoomViewController.title = chatRoom.title
        let chatRoomViewModel = ChatRoomViewModel(
            uid: uid,
            chatRoom: chatRoom,
            navigator: self,
            chatsUsecase: self.services.makeChatsUsecase(),
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            discussionUsecase: self.services.makeDiscussionUsecase()
        )
        chatRoomViewController.viewModel = chatRoomViewModel
        self.navigationController.pushViewController(chatRoomViewController, animated: true)
        self.navigationController.tabBarController?.tabBar.isHidden = true
        self.presentingViewController = chatRoomViewController
    }

    private func makeTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.75)
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        self.navigationController.navigationBar.standardAppearance = appearance
    }

    func toSideMenu(_ chatRoom: ChatRoom) {
        guard let presentingViewController = presentingViewController
        else { return }
        let navigator = DefaultChatRoomSideMenuNavigator(
            services: self.services,
            presentedViewController: presentingViewController
        )
        navigator.toChatRoomSideMenu(chatRoom)
    }

    func toEnterAlert() -> Observable<Bool> {
        return Observable.create { [unowned self] subscribe in
            let alert = UIAlertController(title: "채팅방 참가",
                                          message: "채팅방에 처음으로 입장했습니다. 참가자로 등록할까요?",
                                          preferredStyle: UIAlertController.Style.alert)
            let exitAction = UIAlertAction(title: "나가기", style: .cancel) {_ in
                subscribe.onNext(false)
                subscribe.onCompleted()
                self.toHome()
            }
            let registAction = UIAlertAction(title: "등록", style: .default) {_ in
                subscribe.onNext(true)
                subscribe.onCompleted()
            }
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

    func toDiscussionResultAlert(result: DiscussionResult) {
        let message: String
        switch result {
        case .win:
            message = "이겼습니다🥳 축하합니다!!"
        case .draw:
            message = "비겼습니다😑"
        case .lose:
            message = "졌습니다...🥲"
        }
        let alert = UIAlertController(title: "결과",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.presentingViewController?.present(alert, animated: true)
    }

    func appear() {
        self.navigationController.tabBarController?.tabBar.isHidden = true
    }

    func disappear() {
        self.navigationController.tabBarController?.tabBar.isHidden = false
    }

}
