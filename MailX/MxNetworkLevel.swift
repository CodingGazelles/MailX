//
//  MxRemoteManager.swift
//  MailX
//
//  Created by Tancrède on 6/5/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import BrightFutures
import Result



class MxNetworkLevel: MxStackLevelProtocol {


    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching through network for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
            
            let error = MxStackError.NetworkError(object: id, message: "Call to generic getObject func for \(T.self) is not supported through network", rootError: nil)
            
            MxLog.debug(error.description)
            promise.failure(error)
            
            
        }
        
        return promise.future
        
    }
    
    
    func getObject<T: MxModelObjectProtocol where T: MxProviderModel>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching through network for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
                
                let error = MxStackError.NetworkError(object: id, message: "Call to getObject for \(T.self) is not supported on network level", rootError: nil)
                
                MxLog.debug(error.description)
                promise.failure(error)
            
        }
        
        return promise.future
        
    }
    
    
    func getObject<T: MxModelObjectProtocol where T: MxMailboxModel>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching through network for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
            
            let error = MxStackError.NetworkError(object: id, message: "Call to getObject for \(T.self) is not supported on network level", rootError: nil)
            
            MxLog.debug(error.description)
            promise.failure(error)
            
        }
        
        return promise.future
        
    }
    
    
    func getObject<T: MxModelObjectProtocol where T: MxLabelModel>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching through network for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
            
            let error = MxStackError.NetworkError(object: id, message: "Func not implemented", rootError: nil)
            
            MxLog.debug(error.description)
            promise.failure(error)
            
        }
        
        return promise.future
        
    }
    
    
    func getObject<T: MxModelObjectProtocol where T: MxMessageModel>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching through network for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        ImmediateExecutionContext {
            
            let error = MxStackError.NetworkError(object: id, message: "Func not implemented", rootError: nil)
            
            MxLog.debug(error.description)
            promise.failure(error)
            
        }
        
        return promise.future
        
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError> {
        
        MxLog.debug("Searching through network for all objects \(T.self)")
        
        let promise = Promise<[T], MxStackError>()
        
        ImmediateExecutionContext {
            
            let error = MxStackError.NetworkError(object: nil, message: "Call to generic getAllObjects for \(T.self) is not supported on network level", rootError: nil)
            
            MxLog.debug(error.description)
            promise.failure(error)
            
            
        }
        
        return promise.future
        
    }
    
    
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
        fatalError("Func not implemented")
    }
    
    func removeObject<T: MxModelObjectProtocol>(id id: MxObjectId) -> Future<T,MxStackError> {
        fatalError("Func not implemented")
    }
    
}