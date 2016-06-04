//
//  LabelModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes



final class MxLabelModel: MxModelType, MxRemotePersistable {
    
    var UID: MxUID
    var remoteId: MxLabelModelId?
    var code: String
    var name: String
    var ownerType: MxLabelOwnerType
    var mailboxUID: MxUID
    
    weak var _dbo: MxLabelDBO?
    
    init(UID: MxUID?
        , remoteId: MxLabelModelId?
        , code: String
        , name: String
        , ownerType: MxLabelOwnerType
        , mailboxUID: MxUID){
        
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.code = code
        self.name = name
        self.ownerType = ownerType
        self.mailboxUID = mailboxUID
    }
}


// MARK: - MxRemotePersistable

extension MxLabelModel: MxLocalPersistable {
    
    var dbo: MxLabelDBO? {
        get {
            return _dbo
        }
        set {
            _dbo = newValue
        }
    }
    
    convenience init?( dbo: MxLabelDBO){
        
        guard let ownerType = MxLabelOwnerType( rawValue: dbo.ownerType) else {
            return nil
        }
        
        let remoteId = MxLabelModelId( value: dbo.remoteId)
        let mailboxUID = MxUID(uid: dbo.UID)
        
        self.init(
            UID: dbo.UID
            , remoteId: remoteId
            , code: dbo.code
            , name: dbo.name
            , ownerType: ownerType
            , mailboxUID: mailboxUID)
        
        self.dbo = dbo
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxModelError> {
        
        MxLog.verbose("Processing: \(#function) on: \(self)")
        
        let db = MxPersistenceManager.defaultManager().db
        
        switch fetchMailboxDBO( mailboxUID: mailboxUID) {
        case let .Success(mailboxDbo):
            
            do {
                try db.operation{ (context, save) throws -> Void in
                    
                    let newLabelDbo: MxLabelDBO = try context.create()
                    
                    newLabelDbo.UID = MxUID()
                    newLabelDbo.remoteId = self.remoteId?.value ?? ""
                    newLabelDbo.code = self.code
                    newLabelDbo.name = self.name
                    newLabelDbo.ownerType = MxLabelOwnerType.SYSTEM.rawValue
                    
                    newLabelDbo.mailbox = mailboxDbo
                    
                    self.dbo = newLabelDbo
                    
                    save()
                }
                
                return .Success(true)
                
            } catch {
                
                return Result.Failure(
                    MxModelError.UnableToExecuteDBOperation(
                        operationType: MxDBOperation.MxCreateOperation
                        , DBOType: MxBusinessObjectEnum.Mailbox
                        , message: "Error while calling context.create on MxLabelDBO on: \(self)"
                        , rootError: error))
            }
            
        case let .Failure(error):
            
            return Result.Failure(
                MxModelError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxFetchOperation
                    , DBOType: MxBusinessObjectEnum.Mailbox
                    , message: "Error while calling fetchMailboxDBO() with args: mailboxUID=\(mailboxUID)"
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
    
    static func fetch( uid uid: MxUID) -> Result<MxLabelModel, MxModelError> {
        fatalError("Func not implemented")
    }
    
    static func fetch( uids uids: [MxUID]) -> Result<[Result<MxLabelModel, MxModelError>], MxDBError> {
        fatalError("Func not implemented")
    }
}

extension MxLabelModel {
    
    static func fetchLabels( mailboxUID mailboxUID: MxUID) -> Result<[Result<MxLabelModel, MxModelError>], MxDBError> {
            
            MxLog.verbose("Processing: \(#function). Args: mailbox=\(mailboxUID)")
            
            return fetchMailboxDBO( mailboxUID: mailboxUID)
                |> { $0.labels}
                |> map(){ $0.toModel()}
            
    }
    
    static func deleteLabels( mailboxUID mailboxUID: MxUID) -> Result< Bool, MxModelError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailbox=\(mailboxUID)")
        
        let db = MxPersistenceManager.defaultManager().db
        
        switch fetchMailboxDBO( mailboxUID: mailboxUID) {
        case let .Success(mailbox):
            
            // one can delete only USER labels
            let labels = mailbox.labels.filter({ $0.ownerType == MxLabelOwnerType.USER.rawValue})
            
            do {
                
                try db.operation { (context, save) throws -> Void in
                    try context.remove(labels)
                    save()
                }
                
                return .Success( true)
                
            } catch {
                
                return .Failure(
                    MxModelError.UnableToExecuteDBOperation(
                        operationType: MxDBOperation.MxDeleteOperation
                        , DBOType: MxBusinessObjectEnum.Label
                        , message: "Error while calling context.remove() with args: labels\(labels)"
                        , rootError: error))
                
            }
        case let .Failure(error):
            return Result.Failure(
                MxModelError.UnableToExecuteDBOperation(
                    operationType: MxDBOperation.MxFetchOperation
                    , DBOType: MxBusinessObjectEnum.Mailbox
                    , message: "Error while calling fetchMailboxDBO with args: mailboxUID\(mailboxUID)"
                    , rootError: error))
        }
    }
}


// MARK: - MxConvertibleToStateObject

extension MxLabelModel: MxConvertibleToStateObject {
    
    func toSO() -> MxLabelSO {
        let so = MxLabelSO(model: self)
        return so
    }
}


// MARK: - Remote Id

final class MxLabelModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}


// MARK: - Label Owner Type

enum MxLabelOwnerType: String {
    case SYSTEM = "SYSTEM"
    case USER = "USER"
}
