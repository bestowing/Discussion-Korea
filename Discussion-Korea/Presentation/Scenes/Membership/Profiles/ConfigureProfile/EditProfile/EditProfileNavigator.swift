//
//  DefaultEnterGuestNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/07/19.
//

import Photos
import RxSwift
import UIKit

final class EditProfileNavigator: BaseNavigator, ConfigureProfileNavigator {

    // MARK: - properties

    private let services: UsecaseProvider
    private let presentedViewController: UIViewController

    private lazy var imagePickerDelegate = ImagePickerDelegate()

    private weak var presentingViewController: UIViewController?

    // MARK: - init/deinit

    init(services: UsecaseProvider, presentedViewController: UIViewController) {
        self.services = services
        self.presentedViewController = presentedViewController
    }

    // MARK: - methods

    func toConfigureProfile(_ userID: String, _ nickname: String?, _ profileURL: URL?) {
        let viewController = EditProfileViewController()
        let viewModel = ConfigureProfileViewModel(
            userID: userID,
            nickname: nickname,
            profileURL: profileURL,
            navigator: self,
            userInfoUsecase: self.services.makeUserInfoUsecase()
        )
        viewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.presentedViewController.present(navigationController, animated: true)
        self.presentingViewController = viewController
    }

    func dismiss() {
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
        // TODO: DefaultAddChatRoomNavigator의 코드와 중복됨
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self.imagePickerDelegate
        self.presentingViewController?.present(imagePicker, animated: true)
        return self.imagePickerDelegate.imageURLSubject
            .do(onNext: { [unowned self] _ in
                self.presentingViewController?.dismiss(animated: true)
            })
    }

    func toErrorAlert(_ error: Error) {
        let message: String
        switch error {
        case RefereceError.nicknameError:
            message = "중복된 닉네임이에요. 다른 닉네임을 입력해주세요"
        default:
            message = "오류가 발생했어요. 재시도해주세요"
        }
        let alert = UIAlertController(
            title: "오류!",
            message: message,
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.presentingViewController?.present(alert, animated: true)
    }

}
