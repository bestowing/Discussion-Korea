//
//  ImagePickerDelegate.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/08/31.
//

import RxSwift
import UIKit

final class ImagePickerDelegate: NSObject,
                                 UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate {

    lazy var imageURLSubject = PublishSubject<URL?>()

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let url = info[UIImagePickerController.InfoKey.imageURL] as? URL
        self.imageURLSubject.onNext(url)
    }

}
