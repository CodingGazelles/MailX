//
//  MxPersistenceManager.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import BrightFutures



class MxDataStackManager {
    
    private static let stack = MxDataStackManager()
    static func sharedInstance() -> MxDataStackManager {
        return stack
    }
    
    private var levels = [MxStackLevelProtocol]()
    
    init() {
        levels.append(MxMemoryLevel())
        levels.append(MxDBLevel())
//        levels.append(MxNetworkLevel())
    }
    
    
    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching in stack for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.async {
            
            var niv = MxStatckLevel.Memory.rawValue
            var found: T?
            let end = self.levels.count
            
            repeat {
                
                // Iterate over all levels in search of the object
                
                let _: Future<T,MxStackError> = self.levels[niv].getObject(id: id)
                    
                    .onSuccess { value in
                        
                        MxLog.debug("Search in stack for id \(id) successed in cache \(niv): \(value)")
                        
                        // Resolve the future (success) and exit the loop because the search is over
                        
                        promise.success(value)
                        found = value
                        
                    }
                    
                    .onFailure { error in
                        
                        switch error {
                        case .SearchFailed:
                            
                            MxLog.debug("Search in stack for id \(id) failed in cache \(niv)")
                            
                        default:
                            
                            MxLog.debug("Search in stack for id \(id) failed in cache \(niv) due to error \(error)")
                            
                        }
                        
                        // Don't resolve the future now because the search will continue on next level
                        
                }
                
                niv += 1
                
            } while niv < end && found == nil
            
            if found != nil {
                
                // The search succeeded
                // Loop over the upper levels to insert the value
                
                while niv > 0 {
                    
                    niv -= 1
                    
                    self.levels[niv].setObject(object: found!)
                    
                }
                
            } else {
                
                // The search has ended without result
                // Bind the future with failure
                
                MxLog.debug("Search in stack for id \(id) failed in all caches")
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Search in stack for id \(id) failed in all caches",
                    rootError: nil)
                
                promise.failure( error)
                
            }
        }
        
        return promise.future
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError> {
        
        MxLog.debug("Getting in stack all objects \(T.self)")
        
        let promise = Promise<[T], MxStackError>()
        
        Queue.global.async {
            
            var niv = MxStatckLevel.Memory.rawValue
            var found: [T]?
            let end = self.levels.count
            
            
            repeat {
                
                // Iterate over all levels in search of the objects
                
                let _: Future<[T],MxStackError> = self.levels[niv].getAllObjects()
                    
                    .onSuccess{ values in
                        
                        if values.count > 0 {
                            
                            // Resolve the future (success) and exit the loop because the search is over
                            
                            promise.success(values)
                            found = values
                            
                        }
                        
                    }
                    
                    .onFailure{ error in
                        
                        // Don't resolve the future now because the search will continue on next level
                        
                        let desc = error.description
                        MxLog.debug("Search in stack for objects \(T.self) failed in cache \(niv) due to error \(desc)")
                        
                }
                
                niv += 1
                
            } while niv < end && ( found != nil && found!.count > 0 )
            
            if found != nil {
                
                // The search succeeded
                // Iterate over the upper levels to insert the values
                
                while niv > 0 {
                    
                    niv -= 1
                    
                    let level = self.levels[niv]
                    
                    for object in found! {
                        level.setObject(object: object)
                    }
                    
                }
                
            } else {
                
                // The search has ended without result
                // Bind the future with failure
                
                MxLog.debug("Search in stack for all objects \(T.self) failed in all caches")
                
                let error = MxStackError.SearchFailed(
                    object: nil,
                    typeName: "\(T.self)",
                    message: "Search in stack for all object \(T.self) failed in all caches",
                    rootError: nil)
                
                promise.failure( error)
                
            }
            
        }
        
        return promise.future
    }
    
    
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
        
        MxLog.debug("Setting in stack object \(object)")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.async {
            
            var niv = MxStatckLevel.Memory.rawValue
//            let end = self.levels.count
            let end = 2
            var set = true
            
            repeat {
                
                // Iterate over all levels to set the object
                
                let _: Future<T,MxStackError> = self.levels[niv].setObject(object: object)
                    
                    .onSuccess { value in
                        
                        MxLog.debug("Succeeded setting object in stack niv \(niv) object \(object)")
                        
                        // Don't resolve the future now because the setting will continue on next level
                        
                    }
                    
                    .onFailure { error in
                        
                        set = false
                        MxLog.error("Failed setting in stack \(niv) object \(object) due to error \(error)")
                        
                        // Don't resolve the future now because the setting will continue on next level
                        
                }
                
                niv += 1
                
            } while niv < end
            
            if set {
               promise.success(object)
            } else {
                
                let error = MxStackError.InsertFailed(
                    object: object,
                    typeName: "\(T.self)",
                    message: "Unable to set in stack object \(object)",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
            }
            
            
        }
        
        return promise.future
    }
    
    
    func removeObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Deleting in stack object \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.async {
        
            var niv = MxStatckLevel.Memory.rawValue
            let end = self.levels.count
            var deleted: T?
            
            repeat {
                
                // Iterate over all levels to set the object
                
                let _: Future<T,MxStackError>= self.levels[niv].removeObject(id: id)
                    
                    .onSuccess { value in
                        
                        deleted = value
                        MxLog.debug("Deleted in stack object \(value) with success in cache \(niv)")
                        
                        // Don't resolve the future now because the setting will continue on next level
                        
                    }
                    
                    .onFailure { error in
                        
                        let desc = error.description
                        MxLog.error("Deleting object \(id) failed in cache \(niv) due to error \(desc)")
                        
                        // Don't resolve the future now because the setting will continue on next level
                        
                }
                
                niv += 1
                
            } while niv < end
            
            if deleted != nil {
                
                promise.success(deleted!)
                
            } else {
                
                let error = MxStackError.DeleteFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Unable to delete in stack object \(T.self) with id \(id)",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
            }
            
            
        }
        
        return promise.future
        
    }
}
