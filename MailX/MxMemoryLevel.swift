//
//  MxMemoryManager.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import BrightFutures



class MxMemoryLevel: MxStackLevelProtocol {
    
    private var _caches: [String:MxMemoryBaseCache]
    
    init() {
        self._caches = ["\(MxProviderModel.self)"   :   MxMemoryCache<MxProviderModel>()    ,
                        "\(MxMailboxModel.self)"    :   MxMemoryCache<MxMailboxModel>()     ,
                        "\(MxLabelModel.self)"      :   MxMemoryCache<MxLabelModel>()       ,
                        "\(MxMessageModel.self)"    :   MxMemoryCache<MxMessageModel>()     ]
    }
    
    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("\(#function) searching for object \(T.self) with \(id) in memory cache")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
         
            let cache: MxMemoryCache<T> = self.cache()
            let result = cache.getObject(key: id)
            
            if result != nil {
                
                MxLog.debug("Found \(result)")
                
                promise.success(result!)
                
            } else {
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Failed at searching for object \(T.self) with id \(id) in memory cache",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
            }
            
        }
        
        return promise.future
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[Result<T,MxStackError>],MxStackError> {
        
        MxLog.debug("\(#function) searching for all objects \(T.self) in memory cache")
        
        let promise = Promise<[Result<T,MxStackError>],MxStackError>()
        
        ImmediateExecutionContext {
        
            let cache: MxMemoryCache<T> = self.cache()
            let results = cache.getAllObjects()
            .map{ (mo: T) -> Result<T,MxStackError> in
                return .Success( mo ) }
        
            MxLog.debug("Search succeeded \(results)")
            
            promise.success( results)
            
        }
        
        return promise.future
    }
    
    
    func setObject<T: MxModelObjectProtocol>( object object: T) -> Future<T,MxStackError> {
        
        MxLog.debug("\(#function) inserting object \(object) in memory cache")
        
        let promise = Promise<T,MxStackError>()
        
        ImmediateExecutionContext {
        
            let cache: MxMemoryCache<T> = self.cache()
            cache.setObject(object: object, key: object.id)
            
            MxLog.debug("Set succeeded \(object)")
            
            promise.success(object)
            
        }
        
        return promise.future
    }
    

    func removeObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("\(#function) removing object \(T.self) with \(id) from memory cache")
        
        let promise = Promise<T,MxStackError>()
        
        ImmediateExecutionContext {
            
            let cache: MxMemoryCache<T> = self.cache()
            let result = cache.removeObject(key: id)
            
            if result != nil {
                
                MxLog.debug("Remove succeeded \(result!)")
                
                promise.success(result!)
                
            } else {
                
                let error = MxStackError.DeleteFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Failed at deleting of object \(T.self) fwith id \(id) from memory cache",
                    rootError: nil)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
            }
            
        }
        
        return promise.future
        
    }
    
    private func cache<T: MxModelObjectProtocol>() -> MxMemoryCache<T> {
        return _caches["\(T.self)"]! as! MxMemoryCache<T>
    }
    
}