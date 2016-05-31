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
}

protocol MxLocalPersistable {
    associatedtype DBO: MxDBOType
    init?(dbo: DBO)
}

protocol MxRemotePersistable {
    associatedtype Id: MxRemoteId
    var remoteId: Id { get set }
}

protocol MxRemoteId: Hashable, Equatable {
    var value: String { get set }
}

extension MxRemoteId {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==<Id: MxRemoteId>(lhs: Id, rhs: Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


// MARK: - Model Error

enum MxModelError: MxException {
    case UnableToConvertDBOToModel(
        dbo: MxDBOType
        , message: String
        , rootError: ErrorType?)
}