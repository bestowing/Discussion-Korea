//
//  ViewModelType.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/28.
//

import Foundation

protocol ViewModelType {

    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output

}
