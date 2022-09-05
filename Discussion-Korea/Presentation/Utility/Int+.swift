//
//  Int+.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/01.
//

import Foundation

extension Int {

    func numberFormatter() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))
    }

}
