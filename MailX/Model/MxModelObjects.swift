//
//  MxModelObjects.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation

import Result



// MARK: - Root model object

protocol MxModelObjectProtocol: MxBusinessObjectProtocol {
    init()
}


// MARK: - Indicates that Model can be saved in local DB

//protocol MxLocalPersistable: MxModelObjectProtocol {
//    
//    associatedtype DBO: MxBaseDBO
//    var dbo: DBO? { get set }
//    
//}



protocol MxDBOProtocol {
    
    var internalId: String { get set }
    var remoteId: String { get set }
    
}

extension MxDBOProtocol {
    
    var id: MxObjectId {
        get {
            return MxObjectId(internalId: MxInternalId(value: internalId), remoteId: MxRemoteId(value: remoteId))
        }
        set {
            self.internalId = newValue.internalId.value
            self.remoteId = newValue.remoteId.value
        }
    }
    
    static func primaryKey() -> String? {
        return "internalId"
    }
    
}




