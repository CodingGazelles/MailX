//
//  MxManagedObjects.swift
//  MailX
//
//  Created by Tancrède on 6/14/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - Unmanaged objects

protocol MxImplementBusinessObject: Loggable, Hashable, Equatable {}


// MARK: - Unmanaged objects

protocol MxUnmanagedObject: MxImplementBusinessObject {
    var remoteId: MxRemoteId? { get set }
}

extension MxUnmanagedObject {
    var hashValue: Int {
        return (remoteId?.value ?? "").hashValue
    }
}

func ==<T: MxUnmanagedObject>(lhs: T, rhs: T) -> Bool{
    return lhs.remoteId?.value == rhs.remoteId?.value
}


// MARK: - Managed objects

protocol MxManagedObject: MxImplementBusinessObject {
    var internalId: MxInternalId? { get set }
    var remoteId: MxRemoteId? { get set }
}

extension MxManagedObject {
    var hashValue: Int {
        return (internalId?.value ?? "").hashValue
    }
}

func ==<T: MxManagedObject>(lhs: T, rhs: T) -> Bool{
    return lhs.internalId?.value == rhs.internalId?.value
}


