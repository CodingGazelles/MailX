//
//  MxSystemObjects.swift
//  MailX
//
//  Created by Tancrède on 6/14/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - Business object implementation

protocol MxImplementBusinessObject /*: Loggable, Hashable, Equatable*/ {
    var remoteId: MxRemoteId? { get set }
}


// MARK: - Unmanaged objects

protocol MxUnmanagedObject: MxImplementBusinessObject {}

//extension MxUnmanagedObject {
//    var hashValue: Int {
//        return (remoteId?.value ?? "").hashValue
//    }
//}
//
//func ==<T: MxUnmanagedObject>(lhs: T, rhs: T) -> Bool{
//    return lhs.remoteId?.value == rhs.remoteId?.value
//}


// MARK: - Managed objects

protocol MxManagedObject: MxImplementBusinessObject {
    var internalId: MxInternalId? { get set }
}

//extension MxManagedObject {
//    var hashValue: Int {
//        return (internalId?.value ?? "").hashValue
//    }
//}
//
//func ==<T: MxManagedObject>(lhs: T, rhs: T) -> Bool{
//    return lhs.internalId?.value == rhs.internalId?.value
//}


// MARK: - System objects

protocol MxSystemObjectProtocol/*: Loggable, Hashable, Equatable*/ {}


// MARK: - UI State objects

protocol MxStateObjectProtocol: MxSystemObjectProtocol {}


// MARK: - Model objects

protocol MxModelObjectProtocol: class, MxSystemObjectProtocol, MxManagedObject {}


// MARK: - Remote objects

protocol MxRemoteObjectProtocol: class, MxSystemObjectProtocol, MxUnmanagedObject {}


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


