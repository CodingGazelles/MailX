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



//FIXME: - Availbale only for MxMailbox or MxProvider

enum MxStatckLevel: Int {
    case Memory=0
    case DB=1
    case Network=2
}

protocol MxStackLevelProtocol {
    
    func getObject<T: MxModelObjectProtocol>( id id: MxInternalId) -> Future<T,MxStackError>
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError>
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError>
    func removeObject<T: MxModelObjectProtocol>(id id: MxInternalId) -> Future<T,MxStackError>
    
}

protocol MxCacheProtocol {
    
    associatedtype ObjectType: MxSystemObjectProtocol
    
    func getObject( key key: MxInternalId) -> ObjectType?
    func getAllObjects() -> [ObjectType]
    func setObject( object object: ObjectType, key: MxInternalId)
    func removeObject( key key: MxInternalId) -> ObjectType?
    
}


