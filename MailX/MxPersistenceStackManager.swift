//
//  MxPersistenceManager.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



// MARK: - Model object error

class MxPersistenceStackManager {
    
    private static let stack = MxPersistenceStackManager()
    static func sharedInstance() -> MxPersistenceStackManager {
        return stack
    }
    
    private let levels = [MxStackLevelProtocol]()
    enum Level: Int {
        case Memory=0
        case DB=1
        case Network=2
    }
    
    init() {
        levels.append(MxMemoryLevel())
        levels.append(MxDBLevel())
        levels.append(MxNetworkLevel())
    }
    
    func getObject( id id: MxObjectId,
                       objectType: MxModelObjectProtocol.Type,
                       level: Level? = Level.Memory,
                       callback: (Result<MxModelObjectProtocol,MxStackError>) -> Void)
    {
        
        MxLog.debug("\(#function) searching for object \(objectType) with \(id) in cache \(level)")
        
        guard level?.rawValue < levels.count else {
            callback( .Failure( MxStackError.ModelObjectNotFound(id: id, message: "\(level)", rootError: nil)))
        }
        
        let niv = level!.rawValue
        levels[niv].getObject(id: id, objectType: objectType) { result in
            
            switch result {
            case let .Success(object):
                
                callback( .Success(object))
                
            case .Failure( .ModelObjectNotFound):
                
                self.getObject(
                    id: id,
                    objectType: objectType, 
                    level: Level(rawValue: level!.rawValue + 1),
                    callback: callback)
                
            case let .Failure( error):
                
                callback(
                    .Failure(
                        .UndexpectedError(
                            object: id,
                            message: "Undefined error while getting object \(objectType) with \(id)",
                            rootError: error)))
                
            }
        }
    }
    
    func getAllObjects(objectType objectType: MxModelObjectProtocol.Type,
                                 callback: (Result<[Result<MxModelObjectProtocol,MxStackError>],MxError>) -> Void) {
        
        var niv = 0
        let end = levels.count
        var result: [MxModelObjectProtocol]
        
        repeat {
            
            result = levels[niv].getAllObject( objectType: objectType)
            
            niv += 1
        } while result.count != 0 || niv == end
        
        
    }
}
