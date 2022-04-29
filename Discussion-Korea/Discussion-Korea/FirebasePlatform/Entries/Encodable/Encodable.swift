//
//  Encodable.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/29.
//

import Foundation

protocol DomainConvertibleType {

    associatedtype DomainType: Identifiable
    
    init(with domain: DomainType)
    
    func asDomain() -> DomainType

}

//protocol Identifiable {
//
//    var uid: String { get }
//
//}

typealias DomainConvertibleCoding = DomainConvertibleType

//protocol Encodable {
//
//    associatedtype Encoder: DomainConvertibleCoding
//    
//    var encoder: Encoder { get }
//
//}
