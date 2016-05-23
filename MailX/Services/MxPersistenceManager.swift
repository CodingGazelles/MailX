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



private func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}


class MxPersistenceManager {
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = MxPersistenceManager()
    static func defaultManager() -> Result<MxPersistenceManager, MxError> {
        return .Success(sharedInstance)
    }
    
    private init(){}
    
    
    // Mark: - Default DB
    
    lazy var db: RealmDefaultStorage = {
        var configuration = Realm.Configuration()
        configuration.path = databasePath("mailx.realm")
        let _storage = RealmDefaultStorage(configuration: configuration)
        return _storage
    }()
    
    
    // MARK: - Providers
    
    func insertProvider( provider provider: MxProviderModel) -> Result<Bool, MxError> {
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
                MxError.OperationDidThrow(
                    operationName: "context.create()",
                    message: "Error while calling context.create on MxProviderDBO",
                    rootError: error))
        }
    }
    
    
    // MARK: - Mailboxes
    
    func fetchMailbox( mailboxId mailboxId: MxMailboxModelId) -> Result<MxMailboxModel, MxError> {
        MxLog.verbose("... Processing. Args: mailboxId\(mailboxId)")
        
        return fetchMailboxDBO( mailboxId: mailboxId.value)
            |> (flatMap, {$0.toModel()})
    }
    
    func fetchMailboxes() -> Result<MxMailboxModelArray, MxError> {
        MxLog.verbose("... Processing")
        
        let result = fetchMailboxDBOs()
            |> {$0.toModels()}
        
        return result
    }
    
    func insertMailbox( mailbox mailbox: MxMailboxModel) -> Result<Bool, MxError> {
        MxLog.verbose("... Processing. Args: mailbox=\(mailbox)")
        
        let providerId = mailbox.providerId.value
        switch fetchProviderDBO( providerId: providerId) {
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
                    MxError.OperationDidThrow(
                        operationName: "context.create()",
                        message: "Error while calling context.create on MxMailboxDBO",
                        rootError: error))
            }
        
        case let .Failure(error):
            return Result.Failure(
                MxError.OperationDidThrow(
                    operationName: "fetchProviderDBO()",
                    message: "Error while calling fetchProviderDBO() with args: providerId=\(providerId)",
                    rootError: error))
        }
    }
    
    
    // MARK: - Labels
    
    func fetchLabels( mailboxId mailboxId: MxMailboxModelId) -> Result<MxLabelModelArray, MxError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        switch fetchMailboxDBO( mailboxId: mailboxId.value) {
        case let .Success(value):
            
            let result = value
                .labels
                .map( MxLabelDBO.toModel)
            
            return .Success( result)
            
        case let .Failure(error):
            return .Failure(error)
        }
    }
    
    func deleteLabels( mailboxId mailboxId: MxMailboxModelId) -> Result< Bool, MxError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        switch fetchMailboxDBO( mailboxId: mailboxId.value) {
        case let .Success(mailbox):
            
            // one can delete only USER labels
            let labels = mailbox.labels.filter({ $0.ownerType == MxLabelModel.MxLabelOwnerType.USER.rawValue})
            
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
                    MxError.OperationDidThrow(
                        operationName: "context.remove()",
                        message: "Error while calling context.remove() with args: labels\(labels)",
                        rootError: error))
            }
        case let .Failure(error):
            return Result.Failure(error)
        }
    }
    
    
    // MARK: - Messages
    
    func deleteMessages( mailboxId mailboxId: MxMailboxModelId, labelId: MxLabelModelId) -> Result< Bool,MxError>{
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId), labelId=\(labelId)")
        
        switch fetchMessageDBOs(mailboxId: mailboxId.value, labelId: labelId.value) {
        case let .Success(messages):
            do {
                try db.operation { (context, save) throws -> Void in
                    try context.remove(messages)
                    save()
                }
                return .Success( true)
            } catch {
                return .Failure(
                    MxError.OperationDidThrow(
                        operationName: "context.remove()",
                        message: "Error while calling context.remove() with args: messages\(messages)",
                        rootError: error))
            }
            
        case let .Failure(error):
            return .Failure(error)
        }
    }
    
    
    // MARK: - Fetch db objects
    
    private func fetchProviderDBO( providerId providerId: String) -> Result<MxProviderDBO, MxError> {
        MxLog.verbose("... Processing. Args: providerId=\(providerId)")
        
        let predicate: NSPredicate = NSPredicate( format: "id == %@", providerId)
        do {
            let result = try db.fetch(Request<MxProviderDBO>().filteredWith( predicate: predicate)).first
            return Result.Success(result!)
        } catch {
            return Result.Failure(
                MxError.OperationDidThrow(
                    operationName: "db.fetch",
                    message: "Error while fetching provider. Args: providerId=\(providerId)",
                    rootError: error))
        }
    }
    
    private func fetchMailboxDBO( mailboxId mailboxId: String) -> Result<MxMailboxDBO, MxError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        let predicate: NSPredicate = NSPredicate( format: "id == %@", mailboxId)
        do {
            let result = try db.fetch(Request<MxMailboxDBO>().filteredWith( predicate: predicate)).first
            return Result.Success(result!)
        } catch {
            return Result.Failure(
                MxError.OperationDidThrow(
                    operationName: "db.fetch",
                    message: "Error while fetching mailbox. Args: mailboxId=\(mailboxId)",
                    rootError: error))
        }
    }
    
    private func fetchMailboxDBOs() -> Result<MxMailboxDBOs, MxError> {
        MxLog.verbose("... Processing")
        
        do {
            let result = try db.fetch(Request<MxMailboxDBO>())
            return Result.Success(result)
        } catch {
            return Result.Failure(
                MxError.OperationDidThrow(
                    operationName: "db.fetch",
                    message: "Error while fetching mailboxes.",
                    rootError: error))
        }
    }
    
    private func fetchMessageDBOs( mailboxId mailboxId: String, labelId: String) -> Result<MxMessageDBOs, MxError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId), labelId=\(labelId)")
        
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
            return Result.Failure(error)
        }
    }
}
