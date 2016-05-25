//
//  MxLocalStore.swift
//  Hexmail
//
//  Created by Tancrède on 3/19/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation

import RealmSwift
import Result
import Pipes
import SugarRecordRealm



// MARK: - DB Error

enum MxDBOperation {
    case MxInsertOperation
    case MxDeleteOperation
    case MxUodateOperation
    case MxFetchOperation
    case MxCreateOperation
}

enum MxDBError: MxException {
    case UnableToExecuteOperation(
        operationType: MxDBOperation
        , DBOType: MxDataObject
        , message: String
        , rootError: ErrorType?)
    case DataInconsistent(
        object: MxDataObjectType
        , message: String)
}


// MARK: - 

class MxPersistenceManager {
    
    // MARK: - Shared instance
    
    private static let sharedInstance = MxPersistenceManager()
    static func defaultManager() -> MxPersistenceManager {
        return sharedInstance
    }
    
    private init(){}
    
    
    // Mark: - Default DB
    
    lazy var db: RealmDefaultStorage = {
        var configuration = Realm.Configuration()
        configuration.path = databasePath("mailx.realm")
        let _storage = RealmDefaultStorage(configuration: configuration)
        return _storage
    }()
}

private func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}


// MARK: - Providers

func insertProvider(db: RealmDefaultStorage, provider: MxProviderModel) -> Result<Bool, MxDBError> {
    MxLog.verbose("... Processing. Args: provider=\(provider)")
    
    do {
        
        try db.operation{ (context, save) throws -> Void in
            
            let newProviderDbo: MxProviderDBO = try context.create()
            newProviderDbo.id = provider.id.value
            save()
            
        }
        return .Success(true)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxCreateOperation
                , DBOType: MxDataObject.MxProvider
                , message: "Error while calling context.create on MxProviderDBO. Args: provider=\(provider)"
                , rootError: error))
    }
}


// MARK: - Mailboxes

func fetchMailbox( db db: RealmDefaultStorage, mailboxId: MxMailboxModelId)
    -> Result<MxMailboxModel, MxDBError> {
        
        MxLog.verbose("... Processing. Args: mailboxId\(mailboxId)")
        
        switch fetchMailboxDBO( db: db, mailboxId: mailboxId.value) {
        case let .Success(mailboxDBO):
            return mailboxDBO
                |> {$0.toModel()}
            
        case let .Failure(error):
            return .Failure(MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxMailbox
                , message: "Error while calling fetchMailboxDBO with args: mailboxId: \(mailboxId)"
                , rootError: error))
        }
}

//func fetchMailboxes( db db: RealmDefaultStorage)
//    -> Result<[Result<MxMailboxModel,MxDBError>], MxDBError> {
//        
//        return fetchMailboxDBOs(db: db)
//            |> map({$0.toModel()})
//}

func insertMailbox( db db: RealmDefaultStorage, mailbox: MxMailboxModel) -> Result<Bool, MxDBError> {
    MxLog.verbose("... Processing. Args: mailbox=\(mailbox)")
    
    let providerId = mailbox.providerId.value
    
    switch fetchProviderDBO( db: db, providerId: providerId) {
    case let .Success(provider):
        
        do {
            try db.operation{ (context, save) throws -> Void in
                
                let newMailboxDbo: MxMailboxDBO = try context.create()
                newMailboxDbo.id = mailbox.id.value
                newMailboxDbo.provider = provider
                
                // insert system labels
                let appProperties = HXAppProperties.defaultProperties()
                let providerLabels = appProperties.systemLabels( mailbox.providerId.value).values
                
                let _ = try providerLabels.map({labelId throws -> Void in
                    
                    let labelProperty = appProperties.labelWithLabelId( labelId)
                    
                    let newLabelDbo: MxLabelDBO = try context.create()
                    
                    newLabelDbo.id = labelId
                    newLabelDbo.name = labelProperty[ k_Label_Name]!
                    newLabelDbo.ownerType = MxLabelModel.MxLabelOwnerType.SYSTEM.rawValue
                    newLabelDbo.mailbox = newMailboxDbo
                    
                })
                
                save()
            }
            
            return .Success(true)
            
        } catch {
            
            return Result.Failure(
                MxDBError.UnableToExecuteOperation(
                    operationType: MxDBOperation.MxCreateOperation
                    , DBOType: MxDataObject.MxMailbox
                    , message: "Error while calling context.create on MxMailboxDBO. Args: mailbox=\(mailbox)"
                    , rootError: error))
        }
        
    case let .Failure(error):
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxProvider
                , message: "Error while calling fetchProviderDBO() with args: providerId=\(providerId)"
                , rootError: error))
    }
}


// MARK: - Labels

func fetchLabels( db db: RealmDefaultStorage, mailboxId: MxMailboxModelId)
    -> Result<[Result<MxLabelModel, MxDBError>], MxDBError> {
        
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        switch fetchMailboxDBO( db: db, mailboxId: mailboxId.value) {
        case let .Success(value):
            
            let result = value.labels
                |> map({$0.toModel()})
            
            return .Success( result)
            
        case let .Failure(error):
            return .Failure(error)
        }
}

func deleteLabels( db db: RealmDefaultStorage, mailboxId: MxMailboxModelId)
    -> Result< Bool, MxDBError> {
        
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        switch fetchMailboxDBO( db: db, mailboxId: mailboxId.value) {
        case let .Success(mailbox):
            
            // one can delete only USER labels
            let labels = mailbox.labels.filter({ $0.ownerType == MxLabelOwnerType.USER.rawValue})
            
            // delete only labels whose ids are passed in as argument
            //            if (labelIds != nil) {
            //                let labelIdsValues: [String] = labelIds!.map({$0.value})
            //                labels = labels.filter({ labelIdsValues.contains( $0.id)})
            //            }
            
            do {
                
                try db.operation { (context, save) throws -> Void in
                    try context.remove(labels)
                    save()
                }
                
                // return array of ids of deleted labels
                return .Success( true)
                
            } catch {
                
                return .Failure(
                    MxDBError.UnableToExecuteOperation(
                        operationType: MxDBOperation.MxDeleteOperation
                        , DBOType: MxDataObject.MxLabel
                        , message: "Error while calling context.remove() with args: labels\(labels)"
                        , rootError: error))
                
            }
        case let .Failure(error):
            return Result.Failure(error)
        }
}


// MARK: - Messages

func deleteMessages( db db: RealmDefaultStorage, mailboxId: MxMailboxModelId, labelId: MxLabelModelId)
    -> Result< Bool,MxDBError> {
        
    MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId), labelId=\(labelId)")
    
    switch fetchMessageDBOs(db: db, mailboxId: mailboxId.value, labelId: labelId.value) {
    case let .Success(messages):
        do {
            
            try db.operation { (context, save) throws -> Void in
                try context.remove(messages)
                save()
            }
            return .Success( true)
            
        } catch {
            
            return .Failure(
                MxDBError.UnableToExecuteOperation(
                    operationType: MxDBOperation.MxDeleteOperation
                    , DBOType: MxDataObject.MxMessage
                    , message: "Error while calling context.remove() with args: messages\(messages)"
                    , rootError: error))
        }
        
    case let .Failure(error):
        return .Failure(error)
    }
}


// MARK: - Fetch db objects

func fetchProviderDBO( db db: RealmDefaultStorage, providerId: String) -> Result<MxProviderDBO, MxDBError> {
    
    MxLog.verbose("... Processing. Args: providerId=\(providerId)")
    
    let predicate: NSPredicate = NSPredicate( format: "id == %@", providerId)
    do {
        
        let result = try db.fetch(Request<MxProviderDBO>().filteredWith( predicate: predicate)).first
        return Result.Success(result!)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxProvider
                , message: "Error while fetching provider. Args: providerId=\(providerId)"
                , rootError: error))
    }
}

func fetchMailboxDBO( db db: RealmDefaultStorage, mailboxId: String) -> Result<MxMailboxDBO, MxDBError> {
    
    MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
    
    let predicate: NSPredicate = NSPredicate( format: "id == %@", mailboxId)
    do {
        
        let result = try db.fetch(Request<MxMailboxDBO>().filteredWith( predicate: predicate)).first
        return Result.Success(result!)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxMailbox
                , message: "Error while fetching mailbox. Args: mailboxId=\(mailboxId)"
                , rootError: error))
    }
}

func fetchMailboxDBOs( db db: RealmDefaultStorage) -> Result<[MxMailboxDBO], MxDBError> {
    
    MxLog.verbose("... Processing")
    
    do {
        
        let result = try db.fetch(Request<MxMailboxDBO>())
        return Result.Success(result)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxMailbox
                , message: "Error while fetching mailboxes."
                , rootError: error))
    }
}

func fetchMessageDBOs( db db: RealmDefaultStorage, mailboxId: String, labelId: String)
    -> Result<MxMessageDBOs, MxDBError> {
        
    MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId), labelId=\(labelId)")
    
    switch fetchMailboxDBO( db: db, mailboxId: mailboxId) {
    case let .Success(value):
        
        let result = value
            .labels
            .filter { (label: MxLabelDBO) -> Bool in
                return label.id == labelId }
            .first!
            .messages
        return Result.Success( result)
        
    case let .Failure(error):
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: MxDataObject.MxMailbox
                , message: "Error while fetching mailbox \(mailboxId)"
                , rootError: error))
    }
}

