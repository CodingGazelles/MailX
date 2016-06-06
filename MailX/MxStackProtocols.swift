//
//  MxCache.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



protocol MxStackLevelProtocol {
    
    func getObject(
        id id: MxObjectId,
           objectType: Any.Type,
           callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    
    func getAllObjects(
        objectType objectType: Any.Type,
                   callback: (Result<[Result<MxModelObjectProtocol,MxStackError>],MxStackError>) -> Void)
    
    func setObject(
        object object: MxModelObjectProtocol,
               objectType: Any.Type,
               callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    
    func removeObject(
        id id: MxObjectId,
           objectType: Any.Type,
           callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    
}

protocol MxCacheProtocol {
    
    associatedtype ObjectType: MxBusinessObjectProtocol
    
    func getObject( key key: MxObjectId) -> ObjectType?
    func getAllObjects() -> [ObjectType]
    func setObject( object object: ObjectType, key: MxObjectId)
    func removeObject( key key: MxObjectId) -> ObjectType?
    
}


