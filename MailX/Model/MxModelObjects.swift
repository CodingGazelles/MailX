//
//  MxModelObjects.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation

import Result



// MARK: - Root model object

protocol MxModelType: class, MxBusinessObjectType {}


// MARK: - Indicates that Model can be saved in local DB

protocol MxLocalPersistable {
    
    associatedtype DBO: MxDBOType
    
    weak var dbo: DBO? { get set }
    
    init?(dbo: DBO)
    
    // Fetch
    static func fetch( uid uid: MxUID) -> Result<Self, MxModelError>
    static func fetch( uids uids: [MxUID]) -> Result<[Result<Self, MxModelError>], MxDBError>
    
    // Insert
    func insert() -> Result<Bool,MxModelError>
    
    // Delete
    func delete() -> Result<Bool,MxModelError>
    static func delete( uids uids: [MxUID]) -> Result<Bool, MxModelError>
    
    // Update
    func update() -> Result<Bool,MxModelError>
    
    
}


// MARK: - Indicates that Model can be represented by a State Object

protocol MxConvertibleToStateObject {
    associatedtype SO: MxInitWithModel
    func toSO() -> SO
}


// MARK: - Indicates that Model can be sync with remote provider

protocol MxRemotePersistable {
    associatedtype Id: MxRemoteId
    var remoteId: Id? { get set }
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
    
    case UnableToExecuteDBOperation(
        operationType: MxDBOperation
        , DBOType: MxBusinessObjectEnum
        , message: String
        , rootError: ErrorType?)
    
    case UnableToConvertModelToSO(
        model: MxModelType
        , message: String
        , rootError: ErrorType?)
}




