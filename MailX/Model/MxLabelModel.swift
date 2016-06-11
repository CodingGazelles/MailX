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
import RealmSwift



final class MxLabelModel: Object, MxModelObjectProtocol {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var ownerType: String = MxLabelOwnerType.UNDEFINED.rawValue
    
    // relationships
    let messages = LinkingObjects(fromType: MxMessageModel.self, property: "labels")
    dynamic var mailbox: MxMailboxModel?
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
    override static func primaryKey() -> String? {
        return "internalId"
    }
    
}


// MARK: - MxRemotePersistable

//extension MxLabelModel: MxLocalPersistable {
//    
//    convenience init?( dbo: MxLabelDBO){
//        
//        guard let ownerType = MxLabelOwnerType( rawValue: dbo.ownerType) else {
//            return nil
//        }
//        
//        self.init(
//            id: dbo.id
//            , code: dbo.code
//            , name: dbo.name
//            , ownerType: ownerType
//            , mailboxId:
//                MxObjectId(
//                    internalId: MxInternalId( value: dbo.mailboxInternalId),
//                    remoteId: MxRemoteId( value: dbo.mailboxRemoteId))
//        )
//        
//        
//    }
//    
//    func updateDBO(dbo dbo: MxLabelDBO) {
//        
//        dbo.id = self.id
//        dbo.code = self.code
//        dbo.name = self.name
//        dbo.ownerType = MxLabelOwnerType.SYSTEM.rawValue
//        dbo.mailboxInternalId = self.mailboxId.internalId.value
//        dbo.mailboxRemoteId = self.mailboxId.remoteId.value
//        
//    }
//    
//}

//    // MARK: - Insert
//    
//    func insert() -> Result<Bool, MxStackError> {
//        
//        MxLog.verbose("Processing: \(#function) on: \(self)")
//        
//        let db = MxDBLevel.defaultManager().db
//        
//        switch fetchMailboxDBO( mailboxId: mailboxId) {
//        case let .Success(mailboxDbo):
//            
//            do {
//                try db.operation{ (context, save) throws -> Void in
//                    
//                    let newLabelDbo: MxLabelDBO = try context.create()
//                    
//                    newLabelDbo.id = self.id
//                    newLabelDbo.code = self.code
//                    newLabelDbo.name = self.name
//                    newLabelDbo.ownerType = MxLabelOwnerType.SYSTEM.rawValue
//                    
//                    newLabelDbo.mailbox = mailboxDbo
//                    
//                    save()
//                }
//                
//                return .Success(true)
//                
//            } catch {
//                
//                return Result.Failure(
//                    MxStackError.UnableToExecuteDBOperation(
//                        operationType: MxDBOperation.MxCreateOperation
//                        , DBOType: MxLabelDBO.self
//                        , message: "Error while calling context.create on MxLabelDBO on: \(self)"
//                        , rootError: error))
//            }
//            
//        case let .Failure(error):
//            
//            return Result.Failure(
//                MxStackError.UnableToExecuteDBOperation(
//                    operationType: MxDBOperation.MxFetchOperation
//                    , DBOType: MxMailboxDBO.self
//                    , message: "Error while calling fetchMailboxDBO() with args: mailboxId=\(mailboxId)"
//                    , rootError: error))
//        }
//    }
    
    
//    // MARK: - Delete
//    
//    func delete() -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    
//    // MARK: - Update
//    
//    func update() -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    
//    // MARK: - Fetch
//    
//    static func fetch( uid uid: MxInternalId) -> Result<MxLabelModel, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<MxLabelModel, MxStackError>], MxDBError> {
//        fatalError("Func not implemented")
//    }


//extension MxLabelModel {
//    
//    static func fetchLabels( mailboxId mailboxId: MxObjectId) -> Result<[Result<MxLabelModel, MxStackError>], MxDBError> {
//            
//            MxLog.verbose("Processing: \(#function). Args: mailbox=\(mailboxId)")
//            
//            return fetchMailboxDBO( mailboxId: mailboxId)
//                |> { $0.labels}
//                |> map(){ $0.toModel()}
//            
//    }
//    
//    static func deleteLabels( mailboxId mailboxId: MxObjectId) -> Result< Bool, MxStackError> {
//        
//        MxLog.verbose("Processing: \(#function). Args: mailbox=\(mailboxId)")
//        
//        let db = MxDBLevel.defaultManager().db
//        
//        switch fetchMailboxDBO( mailboxId: mailboxId) {
//        case let .Success(mailbox):
//            
//            // one can delete only USER labels
//            let labels = mailbox.labels.filter({ $0.ownerType == MxLabelOwnerType.USER.rawValue})
//            
//            do {
//                
//                try db.operation { (context, save) throws -> Void in
//                    try context.remove(labels)
//                    save()
//                }
//                
//                return .Success( true)
//                
//            } catch {
//                
//                return .Failure(
//                    MxStackError.UnableToExecuteDBOperation(
//                        operationType: MxDBOperation.MxDeleteOperation
//                        , DBOType: MxLabelDBO.self
//                        , message: "Error while calling context.remove() with args: labels\(labels)"
//                        , rootError: error))
//                
//            }
//        case let .Failure(error):
//            return Result.Failure(
//                MxStackError.UnableToExecuteDBOperation(
//                    operationType: MxDBOperation.MxFetchOperation
//                    , DBOType: MxMailboxModel.self
//                    , message: "Error while calling fetchMailboxDBO with args: mailboxId\(mailboxId)"
//                    , rootError: error))
//        }
//    }
//}


//// MARK: - MxConvertibleToStateObject
//
//extension MxLabelModel {
//    
//    func toSO() -> MxLabelSO {
//        let so = MxLabelSO(model: self)
//        return so
//    }
//}


// MARK: - Label Owner Type

enum MxLabelOwnerType: String {
    case SYSTEM = "SYSTEM"
    case USER = "USER"
    case UNDEFINED = "UNDEFINED"
}
