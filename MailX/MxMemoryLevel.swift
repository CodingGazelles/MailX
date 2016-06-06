//
//  MxMemoryManager.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



class MxMemoryLevel: MxStackLevelProtocol {
    
    private var _caches: [String:MxMemoryBaseCache]
    
    init() {
        self._caches = ["\(MxProviderModel.self)"   :   MxMemoryCache<MxProviderModel>()    ,
                        "\(MxMailboxModel.self)"    :   MxMemoryCache<MxMailboxModel>()     ,
                        "\(MxLabelModel.self)"      :   MxMemoryCache<MxLabelModel>()       ,
                        "\(MxMessageModel.self)"    :   MxMemoryCache<MxMessageModel>()     ]
    }
    
    func getObject( id id: MxObjectId, objectType: Any.Type, callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void) {
        
        let result = cache(objectType: objectType).getObject(key: id)
        
        guard result != nil else {
            
            return callback( .Failure( MxStackError.ModelObjectNotFound(
                id: id,
                message: nil,
                rootError: nil)))
        }
        
        callback( .Success(result!))
    }
    
    func getAllObjects(
        objectType objectType: Any.Type,
                   callback: (Result<[Result<MxModelObjectProtocol,MxStackError>],MxStackError>) -> Void)
    {
        
        let results = cache(objectType: objectType).getAllObjects()
            .map{ (mo: MxModelObjectProtocol) -> Result<MxModelObjectProtocol,MxStackError> in
                return .Success( mo ) }
        
        callback( .Success(results))
        
    }
    
    func setObject(
        object object: MxModelObjectProtocol,
               objectType: Any.Type,
               callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    {
        
        cache(objectType: objectType).setObject(object: object, key: object.id)
        callback( .Success(object))
        
    }

    func removeObject(
        id id: MxObjectId,
           objectType: Any.Type,
           callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    {
        
        let result = cache(objectType: objectType).removeObject(key: id)
        
        guard result != nil else {
            
            return callback( .Failure( MxStackError.ModelObjectNotFound(
                id: id,
                message: nil,
                rootError: nil)))
        }
        
        callback( .Success(result!))
        
    }
    
    private func cache(objectType objectType: Any.Type) -> MxMemoryBaseCache {
        return _caches["\(objectType)"]!
    }
    
}