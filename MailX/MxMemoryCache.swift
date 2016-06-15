//
//  MxMemoryCache.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxMemoryBaseCache {}

class MxMemoryCache<ObjectType: MxModelObjectProtocol>: MxMemoryBaseCache, MxCacheProtocol {
    
    
    private var _cache = [MxInternalId:ObjectType]()
    
    func getObject(key key: MxInternalId) -> ObjectType? {
        return _cache[key]
    }
    
    func getAllObjects() -> [ObjectType] {
        return _cache.map{ (key, object) in
            return object
        }
    }
    
    func setObject(object object: ObjectType, key: MxInternalId) {
        _cache[key] = object
    }
    
    func removeObject(key key: MxInternalId) -> ObjectType? {
        return _cache.removeValueForKey(key)
    }
    
}



