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
        fatalError("Func not implemented")
    }
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError> {
        fatalError("Func not implemented")
    }
    
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
        fatalError("Func not implemented")
    }
    
    func removeObject<T: MxModelObjectProtocol>(id id: MxObjectId) -> Future<T,MxStackError> {
        fatalError("Func not implemented")
    }
    
}