//
//  MxCache.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import BrightFutures



enum MxStatckLevel: Int {
    case Memory=0
    case DB=1
    case Network=2
}

protocol MxStackLevelProtocol {
    
    
    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError>
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError>
    
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError>
    
    func removeObject<T: MxModelObjectProtocol>(id id: MxObjectId) -> Future<T,MxStackError>
    
}

protocol MxCacheProtocol {
    
    associatedtype ObjectType: MxBusinessObjectProtocol
    
    func getObject( key key: MxObjectId) -> ObjectType?
    func getAllObjects() -> [ObjectType]
    func setObject( object object: ObjectType, key: MxObjectId)
    func removeObject( key key: MxObjectId) -> ObjectType?
    
}


