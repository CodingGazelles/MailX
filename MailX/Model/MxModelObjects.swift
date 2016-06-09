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

protocol MxModelObjectProtocol: class, MxBusinessObjectProtocol {}

//typealias MxMOResult = Result<MxModelObjectProtocol,MxStackError>
//typealias MxSOResult = Result<MxStateObjectProtocol,MxSOError>


// MARK: - Indicates that Model can be saved in local DB

protocol MxLocalPersistable: MxModelObjectProtocol {
    
    associatedtype DBO: MxDBOType
    
    init?(dbo: DBO)
    
    func updateDBO( dbo dbo: DBO)
    
//    // Fetch
//    static func fetch( uid uid: MxInternalId) -> Result<Self, MxStackError>
//    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<Self, MxStackError>], MxDBError>
//    
//    // Insert
//    func insert() -> Result<Bool,MxStackError>
//    
//    // Delete
//    func delete() -> Result<Bool,MxStackError>
//    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError>
//    
//    // Update
//    func update() -> Result<Bool,MxStackError>
    
    
}





