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



// MARK: - Model object error

class MxStackManager {
    
    private static let stack = MxStackManager()
    static func sharedInstance() -> MxStackManager {
        return stack
    }
    
    private let levels = [MxStackLevelProtocol]()
    
    init() {
        levels.append(MxMemoryLevel())
        levels.append(MxDBLevel())
        levels.append(MxNetworkLevel())
    }
    
    
    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.async {
            
            var niv = MxStatckLevel.Memory.rawValue
            var found: T?
            let end = self.levels.count
            
            repeat {
                
                // Iterate over all levels in search of the object
                
                self.levels[niv].getObject(id: id)
                    
                    .onSuccess { value in
                        
                        MxLog.debug("Search for id \(id) successed in cache \(niv): \(value)")
                        
                        // Resolve the future (success) and exit the loop because the search is over
                        
                        promise.success(value)
                        found = value
                        
                    }
                    
                    .onFailure { error in
                        
                        switch error {
                        case .SearchFailed:
                            
                            MxLog.debug("Search for id \(id) failed in cache \(niv)")
                            
                        default:
                            
                            MxLog.debug("Search for id \(id) failed in cache \(niv) due to error \(error)")
                            
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
                
                MxLog.debug("Search for id \(id) failed in all caches")
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Search for id \(id) failed in all caches",
                    rootError: nil)
                
                promise.failure( error)
                
            }
        }
        
        return promise.future
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[Result<T,MxStackError>],MxStackError> {
        
        MxLog.debug("Getting all object \(T.self)")
        
        let promise = Promise<[Result<T,MxStackError>], MxStackError>()
        
        Queue.global.async {
            
            var niv = MxStatckLevel.Memory.rawValue
            var found: [T]?
            let end = self.levels.count
            
            
            repeat {
                
                // Iterate over all levels in search of the objects
                
                self.levels[niv].getAllObjects()
                    
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
                        MxLog.debug("Search for objects \(T.self) failed in cache \(niv) due to error \(desc)")
                        
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
                
                MxLog.debug("Search for all objects \(T.self) failed in all caches")
                
                let error = MxStackError.SearchFailed(
                    object: nil,
                    typeName: "\(T.self)",
                    message: "Search for all object \(T.self) failed in all caches",
                    rootError: nil)
                
                promise.failure( error)
                
            }
            
        }
        
        return promise.future
    }
}
