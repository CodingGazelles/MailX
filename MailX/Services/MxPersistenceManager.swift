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


// MARK: - Fetch
// MARK: Provider


// MARK: Mailbox

func fetchMailbox( mailboxId mailboxId: MxMailboxModelId)
    -> Result<MxMailboxModelResult, MxDBError> {
        
        return fetchMailboxDBO( mailboxId: mailboxId.value)
            |> { toModel(mailbox: $0) }
        
}

func fetchMailboxes()
    -> Result<[MxMailboxModelResult], MxDBError> {
        
        return fetchMailboxDBOs()
            |> map(){toModel(mailbox: $0)}
}


// MARK: Label

func fetchLabels( mailboxId mailboxId: MxMailboxModelId)
    -> Result<[Result<MxLabelModel, MxModelError>], MxDBError> {
        
        return fetchMailboxDBO( mailboxId: mailboxId.value)
            |> { $0.labels}
            |> map(){toModel(label: $0)}
        
}


// MARK: - Providers

func insertProvider(db: RealmDefaultStorage, provider: MxProviderModel) -> Result<Bool, MxDBError> {
    MxLog.verbose("Processing: \(#function). Args: provider=\(provider) ")
    
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

func insertMailbox( mailbox: MxMailboxModel) -> Result<Bool, MxDBError> {
    
    MxLog.verbose("Processing: \(#function). Args: mailbox=\(mailbox)")
    
    let providerId = mailbox.providerId.value
    let appProperties = MxAppProperties.defaultProperties()
    let db = MxPersistenceManager.defaultManager().db
    
    switch fetchProviderDBO( providerId: providerId) {
    case let .Success(provider):
        
        do {
            try db.operation{ (context, save) throws -> Void in
                
                let newMailboxDbo: MxMailboxDBO = try context.create()
                
                newMailboxDbo.id = mailbox.id.value
                newMailboxDbo.provider = provider
                
                // insert system labels
                
                let providerLabels = appProperties.providerLabels( providerId: mailbox.providerId.value).values
                
                let _ = try providerLabels.map({labelCode throws -> Void in
                    
                    let labelName = appProperties.systemLabels().labelName( labelCode: labelCode)
                    
                    let newLabelDbo: MxLabelDBO = try context.create()
                    
                    newLabelDbo.id = ""
                    newLabelDbo.code = labelCode
                    newLabelDbo.name = labelName
                    newLabelDbo.ownerType = MxLabelOwnerType.SYSTEM.rawValue
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

func deleteLabels( mailboxId mailboxId: MxMailboxModelId)
    -> Result< Bool, MxDBError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailboxId=\(mailboxId)")
        
        let db = MxPersistenceManager.defaultManager().db
        
        switch fetchMailboxDBO( mailboxId: mailboxId.value) {
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

func deleteMessages( mailboxId mailboxId: MxMailboxModelId, labelId: MxLabelModelId)
    -> Result< Bool,MxDBError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailboxId=\(mailboxId), labelId=\(labelId)")
        
        let db = MxPersistenceManager.defaultManager().db
        
        switch fetchMessageDBOs( mailboxId: mailboxId.value, labelId: labelId.value) {
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


// MARK: - Fetch DBOs

func fetchProviderDBO( providerId providerId: String) -> Result<MxProviderDBO, MxDBError> {
    
    MxLog.verbose("Processing: \(#function). Args: providerId=\(providerId)")
    
    let db = MxPersistenceManager.defaultManager().db
    
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

func fetchMailboxDBO( mailboxId mailboxId: String) -> Result<MxMailboxDBO, MxDBError> {
    
    MxLog.verbose("Processing: \(#function). Args: mailboxId=\(mailboxId)")
    
    let db = MxPersistenceManager.defaultManager().db
    
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

func fetchMailboxDBOs() -> Result<[MxMailboxDBO], MxDBError> {
    
    MxLog.verbose("Processing: \(#function)")
    
    let db = MxPersistenceManager.defaultManager().db
    
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

func fetchMessageDBOs( mailboxId mailboxId: String, labelId: String)
    -> Result<MxMessageDBOs, MxDBError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailboxId=\(mailboxId), labelId=\(labelId)")
        
        switch fetchMailboxDBO( mailboxId: mailboxId) {
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

