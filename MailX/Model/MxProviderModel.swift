//
//  MxProviderModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



//typealias MxProviderModelResult = Result<MxProviderModel, MxDBError>

final class MxProviderModel: MxModelType {
    
    var UID: MxUID
    var code: String
    
    weak var _dbo: MxProviderDBO?
    
    init(UID: MxUID?, code: String){
        self.UID = UID ?? MxUID()
        self.code = code
    }
}

extension MxProviderModel: MxLocalPersistable {
    
    var dbo: MxProviderDBO? {
        get {
            return _dbo
        }
        set {
            _dbo = newValue
        }
    }
    
    convenience init( dbo: MxProviderDBO){
        self.init(
            UID: dbo.UID
            , code: dbo.code)
        
        self.dbo = dbo
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxModelError> {
        
        MxLog.verbose("Processing: \(#function). Args: provider=\(self) ")
        
        let db = MxPersistenceManager.defaultManager().db
        
        do {
            
            try db.operation{ (context, save) throws -> Void in
                
                let newProviderDbo: MxProviderDBO = try context.create()
                
                newProviderDbo.UID = self.UID
                newProviderDbo.code = self.code
                
                self.dbo = newProviderDbo
                
                save()
                
            }
            return .Success(true)
            
        } catch {
            
            return Result.Failure(
                MxModelError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxCreateOperation
                    , DBOType: MxBusinessObjectEnum.Provider
                    , message: "Error while calling context.create on MxProviderDBO. Args: provider=\(self)"
                    , rootError: error))
        }
    }
    
    
    // MARK: - Delete
    
    func delete() -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    static func delete( uids uids: [MxUID]) -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Update
    
    func update() -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Fetch
    
    static func fetch( uid uid: MxUID) -> Result<MxProviderModel, MxModelError> {
        fatalError("Func not implemented")
    }
    
    static func fetch( uids uids: [MxUID]) -> Result<[Result<MxProviderModel, MxModelError>], MxDBError> {
        fatalError("Func not implemented")
    }
}

final class MxProviderModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}



