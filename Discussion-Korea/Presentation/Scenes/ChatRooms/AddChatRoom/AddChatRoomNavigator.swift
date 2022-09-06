//
//  AddChatRoomNavigator.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/26.
//

import Foundation
import RxSwift

protocol AddChatRoomNavigator {

    func toAddChatRoom(_ userID: String)
    func toChatRoomList()
    func toSettingAppAlert()
    func toImagePicker() -> Observable<URL?>
    func toErrorAlert(_ error: Error)

}
