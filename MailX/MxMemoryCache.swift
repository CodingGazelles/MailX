//
//  MxMemoryCache.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxMemoryBaseCache {
    
    func setObject( object object: MxBusinessObjectProtocol, key: MxObjectId) {
        fatalError("Function not implemented")
    }
    func getObject( key key: MxObjectId) -> MxModelObjectProtocol? {
        fatalError("Function not implemented")
    }
    func getAllObjects() -> [MxModelObjectProtocol] {
        fatalError("Function not implemented")
    }
    func removeObject( key key: MxObjectId) -> MxModelObjectProtocol? {
        fatalError("Function not implemented")
    }
    
}

class MxMemoryCache<ObjectType: MxModelObjectProtocol>: MxMemoryBaseCache, MxCacheProtocol {
    
    
    private var _cache = [MxObjectId:ObjectType]()
    
    func getObject(key key: MxObjectId) -> ObjectType? {
        return _cache[key]
    }
    
    func getAllObjects() -> [ObjectType] {
        return _cache.map{ (key, object) in
            return object
        }
    }
    
    func setObject(object object: ObjectType, key: MxObjectId) {
        _cache[key] = object
    }
    
    func removeObject(key key: MxObjectId) -> ObjectType? {
        return _cache.removeValueForKey(key)
    }
    
}



