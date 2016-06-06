//
//  MxProviderModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



final class MxProviderModel: MxModelObjectProtocol {
    
    var id: MxObjectId
    var code: String
    var name: String
    
    init( id: MxObjectId, code: String, name: String){
        self.id = id
        self.code = code
        self.name = name
    }
}

extension MxProviderModel: MxLocalPersistable {
    
    convenience init( dbo: MxProviderDBO){
        self.init(
            id: dbo.id
            , code: dbo.code)
        
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxStackError> {
        
        MxLog.verbose("Processing: \(#function). Args: provider=\(self) ")
        
        let db = MxDBLevel.defaultManager().db
        
        do {
            
            try db.operation{ (context, save) throws -> Void in
                
                let newProviderDbo: MxProviderDBO = try context.create()
                
                newProviderDbo.id = self.id
                newProviderDbo.code = self.code
                
                save()
                
            }
            return .Success(true)
            
        } catch {
            
            return Result.Failure(
                MxStackError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxCreateOperation
                    , DBOType: MxProviderDBO.self
                    , message: "Error while calling context.create on MxProviderDBO. Args: provider=\(self)"
                    , rootError: error))
        }
    }
    
    
    // MARK: - Delete
    
    func delete() -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Update
    
    func update() -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Fetch
    
    static func fetch( uid uid: MxInternalId) -> Result<MxProviderModel, MxStackError> {
        fatalError("Func not implemented")
    }
    
    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<MxProviderModel, MxStackError>], MxDBError> {
        fatalError("Func not implemented")
    }
}

//extension MxProviderModel: MxSOConvertibleProtocol {
//    func toSO() -> MxProviderSO {
//        return MxProviderSO(model: self)
//    }
//}



