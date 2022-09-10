//
//  ConfigureProfileNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/07.
//

import Foundation
import RxSwift

protocol ConfigureProfileNavigator {
    func toConfigureProfile(_ userID: String, _ nickname: String?, _ profileURL: URL?)
    func dismiss()
    func toSettingAppAlert()
    func toImagePicker() -> Observable<URL?>
    func toErrorAlert(_ error: Error)
}
