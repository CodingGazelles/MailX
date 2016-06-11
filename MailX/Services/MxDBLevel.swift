//
//  MxLocalStore.swift
//  Hexmail
//
//  Created by Tancrède on 3/19/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation

import RealmSwift
import Result
import Pipes
import BrightFutures



// MARK: -

class MxDBLevel: MxStackLevelProtocol {
    
    
    init(){}
    
    
    // Mark: - Default DB
    
    //    lazy var db: RealmDefaultStorage = {
    //        var configuration = Realm.Configuration()
    //        configuration.path = databasePath("mailx-dog3.realm")
    //        let _storage = RealmDefaultStorage(configuration: configuration)
    //        return _storage
    //    }()
    
    lazy var realm = try! Realm()
    
    
    func getObject<T: MxModelObjectProtocol>( id id: MxObjectId) -> Future<T,MxStackError> {
        fatalError("Func not implemented")
    }

    func getObject<T: MxModelObjectProtocol where T: Object>( id id: MxObjectId) -> Future<T,MxStackError> {
        
        MxLog.debug("Searching in DB for object \(T.self) with \(id)")
        
        let promise = Promise<T, MxStackError>()
        
        Queue.global.sync {
            
            MxLog.debug("Fetching DBO \(T.self) with id \(id)")
            
            let results = self.realm.objects(T).filter( "internalId == \(id.internalId.value)" )
            
            switch results.count {
            case 0:
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "No result while searching in DB for object \(T.self) with id \(id)",
                    rootError: nil)
                
                MxLog.debug(error.description)
                
                promise.failure(error)
                
            case 1:
                
                MxLog.debug("Found \(results.first)")
                
                promise.success(results.first!)
                
            default:
                
                let error = MxStackError.SearchFailed(
                    object: id,
                    typeName: "\(T.self)",
                    message: "Too many results while searching in DB for object \(T.self) with id \(id)",
                    rootError: nil)
                
                MxLog.debug(error.description)
                
                promise.failure(error)
                
            }
            
        }
        
        return promise.future
    }
    
    
    func getAllObjects<T: MxModelObjectProtocol>() -> Future<[T],MxStackError> {
        fatalError("Func not implemented")
    }
    
    func getAllObjects<T: MxModelObjectProtocol where T: Object>() -> Future<[T],MxStackError> {
        
        MxLog.debug("Searching in DB for all objects \(T.self) in DB")
        
        let promise = Promise<[T],MxStackError>()
        
        Queue.global.sync {
            
            MxLog.debug("Fetching in DB DBOs \(T.self)")
            
            let results = self.realm.objects(T)
            
            switch results.count {
            case 0:
                
                let error = MxStackError.SearchFailed(
                    object: nil,
                    typeName: "\(T.self)",
                    message: "No result while searching in DB for objects \(T.self)",
                    rootError: nil)
                
                MxLog.debug(error.description)
                
                promise.failure(error)
                
            default:
                
                let generator = results.generate()
                var objects = [T]()
                while let element = generator.next() {
                    objects.append(element)
                }
                
                MxLog.debug("Found in DB \(objects)")
                
                promise.success(objects)
                
            }
            
        }
        
        return promise.future
        
    }
    
    
    func setObject<T: MxModelObjectProtocol>(object object: T) -> Future<T,MxStackError> {
        
        MxLog.debug("Inserting/updating in DB object \(object)")
        
        let obj: Object = object as! Object
        let promise = Promise<T, MxStackError>()
        
        Queue.global.sync {
            
            do {
                
                try self.realm.write {
                    
//                    let Type = object.dynamicType
                    self.realm.add(obj , update: true)
                    
                    MxLog.debug("Inserted/Updated \(object)")
                    
                }
                
                promise.success(object)
                
            } catch {
                
                let error = MxStackError.SearchFailed(
                    object: object,
                    typeName: "\(T.self)",
                    message: "Failed at inserting/updating  in DB object \(object)",
                    rootError: error)
                
                MxLog.error(error.description)
                
                promise.failure(error)
                
            }
            
        }
        
        
        return promise.future
    }
    
    func removeObject<T: MxModelObjectProtocol>(id id: MxObjectId) -> Future<T,MxStackError> {
        
        fatalError("Func not implemented")
        
    }
}



private func databasePath(name: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
    return documentsPath.stringByAppendingString("/\(name)")
}
