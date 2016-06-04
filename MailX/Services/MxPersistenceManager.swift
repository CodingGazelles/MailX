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
        configuration.path = databasePath("mailx-dog3.realm")
        let _storage = RealmDefaultStorage(configuration: configuration)
        return _storage
    }()
}

private func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}


// MARK: Messages




// MARK: - Fetch DBOs

func fetchProviderDBO( providerCode providerCode: String) -> Result<MxProviderDBO, MxDBError> {
    
    MxLog.verbose("Processing: \(#function). Args: providerCode=\(providerCode)")
    
    let db = MxPersistenceManager.defaultManager().db
    
    let predicate: NSPredicate = NSPredicate( format: "code == %@", providerCode)
    do {
        
        let result = try db.fetch(Request<MxProviderDBO>().filteredWith( predicate: predicate)).first
        return Result.Success(result!)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: Mirror( reflecting: MxProviderDBO()).subjectType
                , message: "Error while fetching provider. Args: providerCode=\(providerCode)"
                , rootError: error))
    }
}

func fetchMailboxDBO( mailboxUID mailboxUID: MxUID) -> Result<MxMailboxDBO, MxDBError> {
    
    MxLog.verbose("Processing: \(#function). Args: mailboxUID=\(mailboxUID)")
    
    let db = MxPersistenceManager.defaultManager().db
    
    let predicate: NSPredicate = NSPredicate( format: "_UID == %@", mailboxUID.value)
    do {
        
        let result = try db.fetch(Request<MxMailboxDBO>().filteredWith( predicate: predicate)).first
        return Result.Success(result!)
        
    } catch {
        
        return Result.Failure(
            MxDBError.UnableToExecuteOperation(
                operationType: MxDBOperation.MxFetchOperation
                , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
                , message: "Error while fetching mailbox. Args: mailboxId=\(mailboxUID)"
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
                , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
                , message: "Error while fetching mailboxes."
                , rootError: error))
    }
}

func fetchMessageDBOs( mailboxUID mailboxUID: MxUID, labelCode: String)
    -> Result<[MxMessageDBO], MxDBError> {
        
        MxLog.verbose("Processing: \(#function). Args: mailboxUID=\(mailboxUID), labelCode=\(labelCode)")
        
        switch fetchMailboxDBO( mailboxUID: mailboxUID) {
        case let .Success(value):
            
            let result = value
                .labels
                .filter { (label: MxLabelDBO) -> Bool in
                    return label.code == labelCode }
                .first!
                .messages
            return Result.Success( result)
            
        case let .Failure(error):
            
            return Result.Failure(
                MxDBError.UnableToExecuteOperation(
                    operationType: MxDBOperation.MxFetchOperation
                    , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
                    , message: "Error while fetching mailbox \(mailboxUID)"
                    , rootError: error))
        }
}

func fetchMessageDBOs( uids uids: [MxUID]) -> Result<[MxMessageDBO], MxDBError> {
        
    MxLog.verbose("Processing: \(#function). Args: uids=\(uids)")
    
    fatalError("Func not implemented")
        
//        switch fetchMailboxDBO( mailboxUID: mailboxUID) {
//        case let .Success(value):
//            
//            let result = value
//                .labels
//                .filter { (label: MxLabelDBO) -> Bool in
//                    return label.code == labelCode }
//                .first!
//                .messages
//            return Result.Success( result)
//            
//        case let .Failure(error):
//            
//            return Result.Failure(
//                MxDBError.UnableToExecuteOperation(
//                    operationType: MxDBOperation.MxFetchOperation
//                    , DBOType: MxBusinessObjectEnum.Mailbox
//                    , message: "Error while fetching mailbox \(mailboxUID)"
//                    , rootError: error))
//        }
}

