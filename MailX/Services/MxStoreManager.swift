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



enum MxDbError : MxError {
    case DbOperationDidFail( operationName: String, errorMessage: String, error: ErrorType?)
    case DbObjectInconsistent( object: MxDBOType, errorMessage: String)
    case DbOperationDidReturnNothing( operationName: String)
    case DbOperationDidReturnTooManyResults( operationName: String)
}

func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}


class MxStoreManager {
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = MxStoreManager()
    static func defaultDb() -> MxStoreManager {
        return sharedInstance
    }
    
    lazy var db: RealmDefaultStorage = {
        var configuration = Realm.Configuration()
        configuration.path = databasePath("mailx.realm")
        let _storage = RealmDefaultStorage(configuration: configuration)
        return _storage
    }()
    
    
    // MARK: - Providers
    
    func insertProvider( provider provider: MxProviderModel) -> Result<Bool, MxDbError> {
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
                MxDbError.DbOperationDidFail(
                    operationName: "context.create",
                    errorMessage: "Error while calling context.create on MxProviderDbObject",
                    error: error))
        }
    }
    
    
    // MARK: - Mailboxes
    
    func fetchMailbox( mailboxId mailboxId: MxModelId) -> Result<MxMailboxModel, MxDbError> {
        MxLog.verbose("... Processing. Args: mailboxId\(mailboxId)")
        
        return fetchMailboxDBO( mailboxId: mailboxId.value)
            |> (flatMap, {$0.toModel()})
    }
    
    func fetchMailboxes() -> Result<MxMailboxModelArray, MxDbError> {
        MxLog.verbose("... Processing")
        
        let result = fetchMailboxDBOs()
            |> {$0.toModels()}
        
        return result
        
//        switch fetchMailboxDBOs() {
//        case let .Success(value):
//            do {
//                let results = try value.map(MxMailboxDBO.toModel)
//                return Result.Success( results)
//            } catch {
//                return Result.Failure(
//                    MxDbError.DbOperationDidFail(
//                        operationName: "MxMailboxDbObject.toModel",
//                        errorMessage: "Error while calling MxMailboxDbObject.toModel",
//                        error: error))
//            }
//        case let .Failure(error):
//            return Result.Failure(error)
//        }
    }
    
    func insertMailbox( mailbox mailbox: MxMailboxModel) -> Result<Bool, MxDbError> {
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
                    MxDbError.DbOperationDidFail(
                        operationName: "context.create",
                        errorMessage: "Error while calling context.create on MxMailboxDbObject",
                        error: error))
            }
        
        case let .Failure(error):
            return Result.Failure(
                MxDbError.DbOperationDidFail(
                    operationName: "MxLocalStoreHelper.fetchProvider",
                    errorMessage: "Error while calling MxLocalStoreHelper.fetchProvider with args: providerId=\(providerId)",
                    error: error))
        }
    }
    
    
    // MARK: - Labels
    
    func fetchLabels( mailboxId mailboxId: MxModelId) -> Result<MxLabelModelArray, MxDbError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        switch fetchMailboxDBO( mailboxId: mailboxId.value) {
        case let .Success(value):
            do {
                let result = try value
                    .labels
                    .map( MxLabelDBO.toModel)
                return .Success( result)
            } catch {
                return Result.Failure(
                    MxDbError.DbOperationDidFail(
                        operationName: "MxLabelObject.toModel",
                        errorMessage: "Error while calling MxLabelObject.toModel with args: labels=\(value.labels)",
                        error: error) )
            }
        case let .Failure(error):
//            sendErrorNotification( message: "Error while calling fetchMailboxObject. Args: mailboxId= \(mailboxId)",error: error)
            return .Failure(error)
        }
    }
    
    func deleteLabels( mailboxId mailboxId: MxModelId) -> Result< [MxModelId], MxDbError> {
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
                return .Success( labels.map({ MxModelId(value: $0.id)}))
            } catch {
                return .Failure(
                    MxDbError.DbOperationDidFail(
                        operationName: "context.remove",
                        errorMessage: "Error while calling context.remove with args: labels\(labels)",
                        error: error))
            }
        case let .Failure(error):
            return Result.Failure(error)
        }
    }
    
    
    // MARK: - Messages
    
    func deleteMessages( mailboxId mailboxId: MxModelId, labelId: MxModelId) -> Result< AnyObject?,MxDbError>{
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId), labelId=\(labelId)")
        
        switch fetchMessageDBOs(mailboxId: mailboxId.value, labelId: labelId.value) {
        case let .Success(messages):
            do {
                try db.operation { (context, save) throws -> Void in
                    try context.remove(messages)
                    save()
                }
                return .Success( nil)
            } catch {
                return .Failure(
                    MxDbError.DbOperationDidFail(
                        operationName: "context.remove",
                        errorMessage: "Error while calling context.remove with args: messages\(messages)",
                        error: error))
            }
            
        case let .Failure(error):
            return Result.Failure(error)
        }
    }
    
    
    // MARK: - Fetch db objects
    
    private func fetchProviderDBO( providerId providerId: String) -> Result<MxProviderDBO, MxDbError> {
        MxLog.verbose("... Processing. Args: providerId=\(providerId)")
        
        let predicate: NSPredicate = NSPredicate( format: "id == %@", providerId)
        do {
            let result = try db.fetch(Request<MxProviderDBO>().filteredWith( predicate: predicate)).first
            return Result.Success(result!)
        } catch {
            return Result.Failure(
                MxDbError.DbOperationDidFail(
                    operationName: "db.fetch",
                    errorMessage: "Error while fetching provider. Args: providerId=\(providerId)",
                    error: error))
        }
    }
    
    private func fetchMailboxDBO( mailboxId mailboxId: String) -> Result<MxMailboxDBO, MxDbError> {
        MxLog.verbose("... Processing. Args: mailboxId=\(mailboxId)")
        
        let predicate: NSPredicate = NSPredicate( format: "id == %@", mailboxId)
        do {
            let result = try db.fetch(Request<MxMailboxDBO>().filteredWith( predicate: predicate)).first
            return Result.Success(result!)
        } catch {
            return Result.Failure(
                MxDbError.DbOperationDidFail(
                    operationName: "db.fetch",
                    errorMessage: "Error while fetching mailbox. Args: mailboxId=\(mailboxId)",
                    error: error))
        }
    }
    
    private func fetchMailboxDBOs() -> Result<MxMailboxDBOs, MxDbError> {
        MxLog.verbose("... Processing")
        
        do {
            let result = try db.fetch(Request<MxMailboxDBO>())
            return Result.Success(result)
        } catch {
            return Result.Failure(
                MxDbError.DbOperationDidFail(
                    operationName: "db.fetch",
                    errorMessage: "Error while fetching mailboxes.",
                    error: error))
        }
    }
    
    private func fetchMessageDBOs( mailboxId mailboxId: String, labelId: String) -> Result<MxMessageDBOs, MxDbError> {
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
