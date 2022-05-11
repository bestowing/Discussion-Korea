//
//  NSObject+identifier.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/02.
//

import Foundation

extension NSObject {

    static var identifier: String { String(describing: self) }

}
