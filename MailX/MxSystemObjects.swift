//
//  MxSystemObjects.swift
//  MailX
//
//  Created by Tancrède on 6/14/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - System objects

protocol MxSystemObjectProtocol: Loggable, Hashable, Equatable {}


// MARK: - UI State objects

protocol MxStateObjectProtocol: MxSystemObjectProtocol {
    //    var internalId: MxInternalId? { get set }
    //    var remoteId: MxRemoteId? { get set }
}


// MARK: - Model objects

protocol MxModelObjectProtocol: class, MxSystemObjectProtocol, MxManagedObject {
//    associatedtype BusinessProtocol: MxCoreBusinessProtocol
    //    var internalId: MxInternalId? { get set }
    //    var remoteId: MxRemoteId? { get set }
}


// MARK: - Remote objects

protocol MxRemoteObjectProtocol: class, MxSystemObjectProtocol, MxUnmanagedObject {
    //    var remoteId: MxRemoteId? { get set }
}


// MARK: - MxInternalId

struct MxInternalId: Hashable, Equatable {
    
    var value: String
    
    init( value: String? = nil) {
        self.value = value ?? NSUUID().UUIDString
    }
    
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxInternalId, rhs: MxInternalId) -> Bool{
    return lhs.value == rhs.value
}


// MARK: - MxRemoteId

struct MxRemoteId: Hashable, Equatable {
    
    var value: String
    
    init( value: String? = nil) {
        self.value = value ?? ""
    }
    
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxRemoteId, rhs: MxRemoteId) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


