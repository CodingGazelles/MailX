//
//  MxModelObjects.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation



// MARK: - Root model object

protocol MxModelType: MxDataObjectType {
    associatedtype Id: MxModelIdType
    var id: Id { get set }
}

protocol MxModelIdType: Hashable, Equatable {
    var value: String { get set }
}

extension MxModelIdType {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==<Id: MxModelIdType>(lhs: Id, rhs: Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}



