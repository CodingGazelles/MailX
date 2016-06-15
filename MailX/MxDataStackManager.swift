//
//  MxPersistenceManager.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData

import Result
import BrightFutures



//TODO: limit functionalities to MxMailbox

class MxDataStackManager {
    
    private static var sharedInstance = {
        return MxDataStackManager()
    }()
    
    static func defaultStack() -> MxDataStackManager {
        return sharedInstance
    }
    
    private var moc: NSManagedObjectContext!
    
    
//    private var levels = [MxStackLevelProtocol]()
    
    private init() {
//        levels.append(MxMemoryLevel())
//        levels.append(MxDBLevel())
    }
    
    func startDBStack() -> Future<Void, MxStackError> {
        
        MxLog.debug("Connecting to DB")
        
        let promise = Promise<Void, MxStackError>()
        
        Queue.global.context {
            
            let props = MxAppProperties.defaultProperties()
            var managedObjectContext: NSManagedObjectContext
            
            guard let modelURL = NSBundle.mainBundle().URLForResource( props.modelName(), withExtension: props.modelExtension()) else {
                
                let error = MxStackError.SetupFailed(
                    message: "Error loading model from bundle",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
                return
            }
            
            guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
                
                let error = MxStackError.SetupFailed(
                    message: "Error initializing Managed Object Model from: \(modelURL)",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
                return
            }
            
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = psc
            
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            
            /* The directory the application uses to store the Core Data store file.
             This code uses a file named "DataModel.sqlite" in the application's documents directory.
             */
            let storeURL = docURL.URLByAppendingPathComponent("MailX01.sqlite")
            
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
                
                MxLog.info( "DB connected")
                
                self.moc = managedObjectContext
                
                promise.success()
                
            } catch {
                
                let stackError = MxStackError.SetupFailed(
                    message: "Error occured while connecting to DB store \(storeURL)",
                    rootError: error)
                
                MxLog.error("Error occured while connecting to DB store \(storeURL)", error: stackError)
                
                promise.failure(stackError)
                
            }
            
        }
        
        return promise.future
        
    }
    
    func getAllMailboxes() -> Result<[MxMailbox], MxStackError> {
        
        MxLog.debug("Fetching all mailboxes")
        
        let fetch = NSFetchRequest(entityName: MxMailbox.modelName)
        
        do {
            let mailboxes = try moc.executeFetchRequest(fetch) as! [MxMailbox]
            
            MxLog.debug( "Found \(mailboxes.count) mailbox(es): \(mailboxes.map{ $0.email } )")
            
            return .Success( mailboxes)
            
        } catch {
            
            let stackError = MxStackError.SetupFailed(
                message: "Failed to fetch mailboxes",
                rootError: error)
            
            MxLog.error("Failed to fetch mailboxes", error: stackError)
            
            return .Failure( stackError)
            
        }
        
    }
    
    func getMailbox( mailboxId mailboxId: MxInternalId) -> Result<MxMailbox, MxStackError> {
        
        MxLog.debug("Fetching mailbox \(mailboxId)")
        
        switch getAllMailboxes() {
        
        case let .Success( results):
            
            let result = results.filter { mailbox -> Bool in
                    mailbox.internalId == mailboxId
            }
            
            guard result.count > 0 else {
                
                let stackError = MxStackError.SetupFailed(
                    message: "Fetch of mailbox returned no result \(mailboxId)",
                    rootError: nil)
                
                MxLog.error("Fetch of mailbox returned no result \(mailboxId)", error: stackError)
                
                return .Failure( stackError)
                
            }
            
            guard !(result.count > 1) else {
                
                let stackError = MxStackError.SetupFailed(
                    message: "Fetch of mailbox returned \(result.count) results \(mailboxId)",
                    rootError: nil)
                
                MxLog.error("Fetch of mailbox returned \(result.count) results \(mailboxId)", error: stackError)
                
                return .Failure( stackError)
                
            }
            
            return .Success( result[0])
            
            
        case let .Failure( error):
            
            let stackError = MxStackError.SetupFailed(
                message: "Failed to fetch mailbox \(mailboxId)",
                rootError: error)
            
            MxLog.error("Failed to fetch mailbox \(mailboxId)", error: stackError)
            
            return .Failure( stackError)
            
        }
        
    }
    
    func createProvider( internalId internalId: MxInternalId,
                                    code: String,
                                    name: String) -> Result<MxProvider, MxNoError> {
        
        let provider = NSEntityDescription.insertNewObjectForEntityForName(MxProvider.modelName, inManagedObjectContext: self.moc) as! MxProvider
        
        provider.internalId = internalId
        provider.code = code
        provider.name = name
        
        return .Success( provider)
        
    }
    
    func createMailbox( internalId internalId: MxInternalId,
                                   remoteId: MxRemoteId,
                                   email: String,
                                   name: String) -> Result<MxMailbox, MxNoError> {
        
        let mailbox = NSEntityDescription.insertNewObjectForEntityForName(MxMailbox.modelName, inManagedObjectContext: self.moc) as! MxMailbox
        
        mailbox.internalId = internalId
        mailbox.remoteId = remoteId
        mailbox.email = email
        mailbox.name = name
        mailbox.connected = false
        
        return .Success( mailbox)
        
    }
    
    func createLabel( internalId internalId: MxInternalId,
                                 remoteId: MxRemoteId,
                                 code: String,
                                 name: String,
                                 ownerType: MxLabelOwnerType) -> Result<MxLabel, MxNoError> {
        
        let label = NSEntityDescription.insertNewObjectForEntityForName(MxLabel.modelName, inManagedObjectContext: self.moc) as! MxLabel
        
        label.internalId = internalId
        label.remoteId = remoteId
        label.code = code
        label.name = name
        label.ownerType = ownerType
        
        return .Success( label)
        
    }
    
    func removeObject( object object: MxBaseManagedObject ) -> Result<Void, MxStackError> {
        
        moc.deleteObject(object)
        return .Success()
        
    }
    
    func saveContext() -> Result< Void, MxStackError> {
        
        do {
            
            try moc.save()
            return .Success()
            
        } catch {
            
            let stackError = MxStackError.SetupFailed(
                message: "Failed to save context",
                rootError: error)
            
            MxLog.error("Failed to save context", error: stackError)
            
            return .Failure( stackError)
            
        }
        
    }
    
    
//    func getObject<T: MxModelObjectProtocol>( id id: MxInternalId) -> Future<T,MxStackError> {
//        
//        MxLog.debug("Searching in stack for object \(T.self) with \(id)")
//        
//        let promise = Promise<T, MxStackError>()
//        
//        Queue.global.async {
//            
//            var niv = MxStatckLevel.Memory.rawValue
//            var found: T?
//            let end = self.levels.count
//            
//            repeat {
//                
//                // Iterate over all levels in search of the object
//                
//                let _: Future<T,MxStackError> = self.levels[niv].getObject(id: id)
//                    
//                    .onSuccess { value in
//                        
//                        MxLog.debug("Search in stack for id \(id) successed in cache \(niv): \(value)")
//                        
//                        // Resolve the future (success) and exit the loop because the search is over
//                        
//                        promise.success(value)
//                        found = value
//                        
//                    }
//                    
//                    .onFailure { error in
//                        
//                        switch error {
//                        case .SearchFailed:
//                            
//                            MxLog.debug("Search in stack for id \(id) failed in cache \(niv)")
//                            
//                        default:
//                            
//                            MxLog.debug("Search in stack for id \(id) failed in cache \(niv) due to error \(error)")
//                            
//                        }
//                        
//                        // Don't resolve the future now because the search will continue on next level
//                        
//                }
//                
//                niv += 1
//                
//            } while niv < end && found == nil
//            
//            if found != nil {
//                
//                // The search succeeded
//                // Loop over the upper levels to insert the value
//                
//                while niv > 0 {
//                    
//                    niv -= 1
//                    
//                    self.levels[niv].setObject(object: found!)
//                    
//                }
//                
//            } else {
//                
//                // The search has ended without result
//                // Bind the future with failure
//                
//                MxLog.debug("Search in stack for id \(id) failed in all caches")
//                
//                let error = MxStackError.SearchFailed(
//                    object: id,
//                    typeName: "\(T.self)",
//                    message: "Search in stack for id \(id) failed in all caches",
//                    rootError: nil)
//                
//                promise.failure( error)
//                
//            }
//        }
//        
//        return promise.future
//    }
//    
//    
//    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError> {
//        
//        MxLog.debug("Getting in stack all objects \(T.self)")
//        
//        let promise = Promise<[T], MxStackError>()
//        
//        Queue.global.async {
//            
//            var niv = MxStatckLevel.Memory.rawValue
//            var found: [T]?
//            let end = self.levels.count
//            
//            
//            repeat {
//                
//                // Iterate over all levels in search of the objects
//                
//                let _: Future<[T],MxStackError> = self.levels[niv].getAllObjects()
//                    
//                    .onSuccess{ values in
//                        
//                        if values.count > 0 {
//                            
//                            // Resolve the future (success) and exit the loop because the search is over
//                            
//                            promise.success(values)
//                            found = values
//                            
//                        }
//                        
//                    }
//                    
//                    .onFailure{ error in
//                        
//                        // Don't resolve the future now because the search will continue on next level
//                        
//                        let desc = error.description
//                        MxLog.debug("Search in stack for objects \(T.self) failed in cache \(niv) due to error \(desc)")
//                        
//                }
//                
//                niv += 1
//                
//            } while niv < end && ( found != nil && found!.count > 0 )
//            
//            if found != nil {
//                
//                // The search succeeded
//                // Iterate over the upper levels to insert the values
//                
//                while niv > 0 {
//                    
//                    niv -= 1
//                    
//                    let level = self.levels[niv]
//                    
//                    for object in found! {
//                        level.setObject(object: object)
//                    }
//                    
//                }
//                
//            } else {
//                
//                // The search has ended without result
//                // Bind the future with failure
//                
//                MxLog.debug("Search in stack for all objects \(T.self) failed in all caches")
//                
//                let error = MxStackError.SearchFailed(
//                    object: nil,
//                    typeName: "\(T.self)",
//                    message: "Search in stack for all object \(T.self) failed in all caches",
//                    rootError: nil)
//                
//                promise.failure( error)
//                
//            }
//            
//        }
//        
//        return promise.future
//    }
//    
//    
//    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
//        
//        MxLog.debug("Setting in stack object \(object)")
//        
//        let promise = Promise<T, MxStackError>()
//        
//        Queue.global.async {
//            
//            var niv = MxStatckLevel.Memory.rawValue
//            //            let end = self.levels.count
//            let end = 2
//            var set = true
//            
//            repeat {
//                
//                // Iterate over all levels to set the object
//                
//                let _: Future<T,MxStackError> = self.levels[niv].setObject(object: object)
//                    
//                    .onSuccess { value in
//                        
//                        MxLog.debug("Succeeded setting object in stack niv \(niv) object \(object)")
//                        
//                        // Don't resolve the future now because the setting will continue on next level
//                        
//                    }
//                    
//                    .onFailure { error in
//                        
//                        set = false
//                        MxLog.error("Failed setting in stack \(niv) object \(object) due to error \(error)")
//                        
//                        // Don't resolve the future now because the setting will continue on next level
//                        
//                }
//                
//                niv += 1
//                
//            } while niv < end
//            
//            if set {
//                promise.success(object)
//            } else {
//                
//                let error = MxStackError.InsertFailed(
//                    object: object,
//                    typeName: "\(T.self)",
//                    message: "Unable to set in stack object \(object)",
//                    rootError: nil)
//                
//                MxLog.error(error.description)
//                
//                promise.failure(error)
//            }
//            
//            
//        }
//        
//        return promise.future
//    }
//    
//    
//    func removeObject<T: MxModelObjectProtocol>( id id: MxInternalId) -> Future<T,MxStackError> {
//        
//        MxLog.debug("Deleting in stack object \(id)")
//        
//        let promise = Promise<T, MxStackError>()
//        
//        Queue.global.async {
//            
//            var niv = MxStatckLevel.Memory.rawValue
//            let end = self.levels.count
//            var deleted: T?
//            
//            repeat {
//                
//                // Iterate over all levels to set the object
//                
//                let _: Future<T,MxStackError>= self.levels[niv].removeObject(id: id)
//                    
//                    .onSuccess { value in
//                        
//                        deleted = value
//                        MxLog.debug("Deleted in stack object \(value) with success in cache \(niv)")
//                        
//                        // Don't resolve the future now because the setting will continue on next level
//                        
//                    }
//                    
//                    .onFailure { error in
//                        
//                        let desc = error.description
//                        MxLog.error("Deleting object \(id) failed in cache \(niv) due to error \(desc)")
//                        
//                        // Don't resolve the future now because the setting will continue on next level
//                        
//                }
//                
//                niv += 1
//                
//            } while niv < end
//            
//            if deleted != nil {
//                
//                promise.success(deleted!)
//                
//            } else {
//                
//                let error = MxStackError.DeleteFailed(
//                    object: id,
//                    typeName: "\(T.self)",
//                    message: "Unable to delete in stack object \(T.self) with id \(id)",
//                    rootError: nil)
//                
//                MxLog.error(error.description)
//                
//                promise.failure(error)
//                
//            }
//            
//            
//        }
//        
//        return promise.future
//        
//    }
}
