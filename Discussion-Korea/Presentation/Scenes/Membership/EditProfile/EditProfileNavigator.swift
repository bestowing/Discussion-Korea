//
//  EditProfileNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import RxSwift

protocol EditProfileNavigator {

    func toEditProfile(_ userID: String, _ nickname: String?, _ profileURL: URL?)
    func toMyPage()
    func toSettingAppAlert()
    func toImagePicker() -> Observable<URL?>
    func toErrorAlert(_ error: Error)

}
