//
//  MxMailboxModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes



//typealias MxMailboxModelResult = Result<MxMailboxModel, MxModelError>

final class MxMailboxModel: MxModelType, MxRemotePersistable {
    
    var UID: MxUID
    var remoteId: MxMailboxModelId?
    var email: String
    var name: String
    var connected: Bool
    var providerCode: String
    
    var proxy: MxMailboxProxy!
    weak var _dbo: MxMailboxDBO?
    
    init(UID: MxUID?, remoteId: MxMailboxModelId?, email: String, name: String, connected: Bool, providerCode: String){
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.email = email
        self.name = name
        self.connected = connected
        self.providerCode = providerCode
    }
}

extension MxMailboxModel: MxLocalPersistable {
    
    var dbo: MxMailboxDBO? {
        get {
            return _dbo
        }
        set {
            _dbo = newValue
        }
    }
    
    convenience init?( dbo: MxMailboxDBO){
        
        guard dbo.provider != nil else {
            return nil
        }
        
        self.init(
            UID: dbo.UID
            , remoteId: MxMailboxModelId( value: dbo.remoteId)
            , email: dbo.email
            , name: dbo.name
            , connected: false
            , providerCode: dbo.provider!.code)
        
        self.dbo = dbo
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxModelError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailbox=\(self)")
        
        let providerCode = self.providerCode
        //        let appProperties = MxAppProperties.defaultProperties()
        let db = MxPersistenceManager.defaultManager().db
        
        switch fetchProviderDBO( providerCode: providerCode) {
        case let .Success(provider):
            
            do {
                try db.operation{ (context, save) throws -> Void in
                    
                    let newMailboxDbo: MxMailboxDBO = try context.create()
                    
                    newMailboxDbo.UID = self.UID
                    newMailboxDbo.remoteId = self.remoteId?.value ?? "nil"
                    newMailboxDbo.email = self.email
                    newMailboxDbo.name = self.name
                    newMailboxDbo.provider = provider
                    
                    self.dbo = newMailboxDbo
                    
                    save()
                }
                
                return .Success(true)
                
            } catch {
                
                return Result.Failure(
                    MxModelError.UnableToExecuteDBOperation(
                        operationType: MxDBOperation.MxCreateOperation
                        , DBOType: MxBusinessObjectEnum.Mailbox
                        , message: "Error while calling context.create on MxMailboxDBO. Args: mailbox=\(self)"
                        , rootError: error))
            }
            
        case let .Failure(error):
            
            return Result.Failure(
                MxModelError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxFetchOperation
                    , DBOType: MxBusinessObjectEnum.Provider
                    , message: "Error while calling fetchProviderDBO() with args: providerCode=\(providerCode)"
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
    
    static func fetch( uid uid: MxUID) -> Result<MxMailboxModel, MxModelError> {
        
        switch fetchMailboxDBO( mailboxUID: uid) {
            
        case let .Success(mailbox):
            return mailbox.toModel()
            
        case let .Failure(error):
            return .Failure(
                MxModelError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxFetchOperation
                    , DBOType: MxBusinessObjectEnum.Mailbox
                    , message: "Error while calling fetchMailboxDBO() with args: mailboxUID=\(uid)"
                    , rootError: error)
            )
        }
        
    }
    
    static func fetch( uids uids: [MxUID]) -> Result<[Result<MxMailboxModel, MxModelError>], MxDBError> {
        fatalError("Func not implemented")
    }
    
}

extension MxMailboxModel {
    
    static func fetch()
        -> Result<[Result<MxMailboxModel, MxModelError>], MxDBError> {
            
            MxLog.debug("\(#function): fetching all mailboxes")
            
            return fetchMailboxDBOs()
                |> map(){ $0.toModel()}
    }
    
}


// MARK: - MxRemoteId

final class MxMailboxModelId: MxRemoteId{
    var value: String
    init( value: String){
        self.value = value
    }
}








