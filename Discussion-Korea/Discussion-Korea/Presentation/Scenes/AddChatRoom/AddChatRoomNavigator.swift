//
//  AddChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import RxSwift
import UIKit

protocol AddChatRoomNavigator {

    func toAddChatRoom(_ userID: String)
    func toChatRoomList()
    func toSettingAppAlert()
    func toImagePicker() -> Observable<URL?>
    func toErrorAlert(_ error: Error)

}

final class DefaultAddChatRoomNavigator: NSObject, AddChatRoomNavigator {

    // MARK: properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private var completion: ((URL?) -> Void)?

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func toAddChatRoom(_ userID: String) {
        let viewController = AddChatRoomViewController()
        let viewModel = AddChatRoomViewModel(
            userID: userID,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase(),
            chatRoomUsecase: self.services.makeChatRoomsUsecase()
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.presentingViewController = viewController
    }

    func toChatRoomList() {
        self.presentedViewController.dismiss(animated: true)
    }

    func toSettingAppAlert() {
        let alert = UIAlertController(
            title: "설정",
            message: "권한이 허용되어있지 않습니다. 설정 앱으로 이동해서 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        let cancle = UIAlertAction(title: "취소", style: .default)
        let confirm = UIAlertAction(title: "확인", style: .default) { (UIAlertAction) in
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(cancle)
        alert.addAction(confirm)
        self.presentingViewController?.present(alert, animated: true)
    }

    func toImagePicker() -> Observable<URL?> {
        return PublishSubject.create { [unowned self] subscribe in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.completion = { url in
                subscribe.onNext(url)
                subscribe.onCompleted()
            }
            self.presentingViewController?.present(imagePicker, animated: true)
            return Disposables.create()
        }.asObservable()
    }

    func toErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "오류!",
            message: "오류가 발생했습니다. 재시도해주세요..",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.presentingViewController?.present(alert, animated: true)
    }

}

extension DefaultAddChatRoomNavigator: UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let url = info[UIImagePickerController.InfoKey.imageURL] as? URL
        self.completion?(url)
        self.presentingViewController?.dismiss(animated: true)
    }

}
