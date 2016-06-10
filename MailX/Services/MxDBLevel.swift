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
import BrightFutures



// MARK: -

class MxDBLevel: MxStackLevelProtocol {
    
    
    init(){}
    
    
    // Mark: - Default DB
    
    //    lazy var db: RealmDefaultStorage = {
    //        var configuration = Realm.Configuration()
    //        configuration.path = databasePath("mailx-dog3.realm")
    //        let _storage = RealmDefaultStorage(configuration: configuration)
    //        return _storage
    //    }()
    
    lazy var realm = try! Realm()
    
    
    //    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
    //
    //        MxLog.debug("Searching for object \(T.self) with \(id) in DB")
    //
    //        let promise = Promise<T, MxStackError>()
    //
    //        ImmediateExecutionContext {
    //
    //            // Model is not convertible to DBO and can't be stored in DB !!!!
    //
    //            let error = MxStackError.SearchFailed(
    //                object: id,
    //                typeName: "\(T.self)",
    //                message: "This object \(T.self) with id \(id) can't be stored in DB",
    //                rootError: nil)
    //
    //            MxLog.error(error.description)
    //
    //            promise.failure(error)
    //        }
    //
    //        return promise.future
    //    }
    
    func getObject<T: MxModelObjectProtocol where T: Object>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching for object \(T.self) with \(id) in DB")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.sync {
            
            MxLog.debug("Fetching DBO \(T.self) with id \(id)")
            
            let results = self.realm.objects(T).filter( "internalId == \(id.internalId.value)" )
            
            switch results.count {
            case 0:
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "No result while searching for object \(T.self) with id \(id) in DB",
                    rootError: nil)
                
                MxLog.debug(error.description)
                
                promise.failure(error)
                
            case 1:
                
                MxLog.debug("Found \(results.first)")
                
                promise.success(results.first!)
                
            default:
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Too many results while searching for object \(T.self) with id \(id) in DB",
                    rootError: nil)
                
                MxLog.debug(error.description)
                
                promise.failure(error)
                
            }
            
        }
        
        return promise.future
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[Result<T,MxStackError>],MxStackError> {
        
        fatalError("Func not implemented")
    }
    
    //    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
    //
    //        MxLog.debug("Inserting object \(object) in DB")
    //
    //        let promise = Promise<T, MxStackError>()
    //
    //        ImmediateExecutionContext {
    //
    //            // Model is not convertible to DBO and can't be stored in DB !!!!
    //
    //            let error = MxStackError.InsertFailed(
    //                object: object,
    //                typeName: "\(T.self)",
    //                message: "This object \(object) can't be stored in DB",
    //                rootError: nil)
    //
    //            MxLog.error(error.description)
    //
    //            promise.failure(error)
    //        }
    //
    //        return promise.future
    //
    //    }
    
    
    func setObject<T: MxModelObjectProtocol where T: Object>(object object: T) -> Future<T,MxStackError> {
        
        MxLog.debug("Inserting/updating object \(object) in DB")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.sync {
            
            do {
                
                try self.realm.write {
                    
                    self.realm.add(object, update: true)
                    
                    MxLog.debug("Inserted/Updated \(object)")
                    
                }
                
                promise.success(object)
                
            } catch {
                
                let error = MxStackError.SearchFailed(
                    object: object,
                    typeName: "\(T.self)",
                    message: "Failed at inserting/updating object \(object) in DB",
                    rootError: error)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
            }
            
        }
        
        
        return promise.future
    }
    
    func removeObject<T: MxModelObjectProtocol>(id id: MxObjectId) -> Future<T,MxStackError> {
        
        fatalError("Func not implemented")
        
    }
    
    
    
    //    private func fetchProviderDBO( providerId providerId: MxObjectId) -> Result<MxProviderDBO, MxDBError> {
    //
    //        MxLog.debug("Processing: \(#function). Args: providerId=\(providerId)")
    //
    //        let predicate: NSPredicate = NSPredicate( format: "internalId == %@", providerId.internalId.value)
    //        do {
    //
    //            let result = try db.fetch(Request<MxProviderDBO>().filteredWith( predicate: predicate)).first
    //
    //            return Result.Success(result!)
    //
    //        } catch {
    //
    //            return Result.Failure(
    //                MxDBError.UnableToExecuteOperation(
    //                    operationType: MxDBOperation.MxFetchOperation
    //                    , DBOType: Mirror( reflecting: MxProviderDBO()).subjectType
    //                    , message: "Error while fetching provider. Args: providerId=\(providerId)"
    //                    , rootError: error))
    //        }
    //    }
    
    //    private func fetchDBO<T: MxDBOProtocol>( id id: MxObjectId) -> Result<T, MxDBError> {
    //
    //        MxLog.debug("Fetching DBO \(T.self) with id \(id)")
    //
    //        do {
    //
    //            let result = try realm.objects(T).filter( "internalId == \(id.internalId.value)" ).first
    //            return Result.Success(result!)
    //
    //        } catch {
    //
    //            return Result.Failure(
    //                MxDBError.FetchError(
    //                    object: id,
    //                    typeName: "\(T.self)",
    //                    message: "Error while fetching \(T.self) with id: \(id)",
    //                    rootError: error))
    //
    //        }
    //    }
    
    //    private func fetchDBOs<T: MxDBOProtocol>() -> Result<[T], MxDBError> {
    //
    //        MxLog.debug("\(#function): fetching \(T.self)")
    //
    //        do {
    //
    //            let result = try realm.objects(T)
    //            return Result.Success(result)
    //
    //        } catch {
    //
    //            return Result.Failure(
    //                MxDBError.FetchError(
    //                    object: nil
    //                    , typeName: "\(T.self)"
    //                    , message: "Error while fetching \(T.self)."
    //                    , rootError: error))
    //        }
    //
    //    }
    
    
    //    private func fetchMailboxDBO( mailboxId mailboxId: MxObjectId) -> Result<MxMailboxDBO, MxDBError> {
    //
    //        MxLog.debug("Processing: \(#function). Args: mailboxId=\(mailboxId)")
    //
    //        let predicate: NSPredicate = NSPredicate( format: "_UID == %@", mailboxId.internalId.value)
    //        do {
    //
    //            let result = try db.fetch(Request<MxMailboxDBO>().filteredWith( predicate: predicate)).first
    //            return Result.Success(result!)
    //
    //        } catch {
    //
    //            return Result.Failure(
    //                MxDBError.UnableToExecuteOperation(
    //                    operationType: MxDBOperation.MxFetchOperation
    //                    , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
    //                    , message: "Error while fetching mailbox. Args: mailboxId=\(mailboxId)"
    //                    , rootError: error))
    //        }
    //    }
    
    //    private func fetchMailboxDBOs() -> Result<[MxMailboxDBO], MxDBError> {
    //
    //        MxLog.verbose("Processing: \(#function)")
    //
    //        do {
    //
    //            let result = try db.fetch(Request<MxMailboxDBO>())
    //            return Result.Success(result)
    //
    //        } catch {
    //
    //            return Result.Failure(
    //                MxDBError.UnableToExecuteOperation(
    //                    operationType: MxDBOperation.MxFetchOperation
    //                    , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
    //                    , message: "Error while fetching mailboxes."
    //                    , rootError: error))
    //        }
    //    }
    
    //    private func fetchMessageDBOs( mailboxId mailboxId: MxObjectId, labelCode: String)
    //        -> Result<[MxMessageDBO], MxDBError> {
    //
    //            MxLog.verbose("Processing: \(#function). Args: mailboxId=\(mailboxId), labelCode=\(labelCode)")
    //
    //            switch fetchMailboxDBO( mailboxId: mailboxId) {
    //            case let .Success(value):
    //
    //                let result = value
    //                    .labels
    //                    .filter { (label: MxLabelDBO) -> Bool in
    //                        return label.code == labelCode }
    //                    .first!
    //                    .messages
    //                return Result.Success( result)
    //
    //            case let .Failure(error):
    //
    //                return Result.Failure(
    //                    MxDBError.UnableToExecuteOperation(
    //                        operationType: MxDBOperation.MxFetchOperation
    //                        , DBOType: Mirror( reflecting: MxMailboxDBO()).subjectType
    //                        , message: "Error while fetching mailbox \(mailboxId)"
    //                        , rootError: error))
    //
    //            }
    //    }
    
    //    private func fetchMessageDBOs( uids uids: [MxObjectId]) -> Result<[MxMessageDBO], MxDBError> {
    //        
    //        MxLog.verbose("Processing: \(#function). Args: uids=\(uids)")
    //        fatalError("Func not implemented")
    //        
    //    }
}




// MARK: Messages




// MARK: - Fetch DBOs



private func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}
