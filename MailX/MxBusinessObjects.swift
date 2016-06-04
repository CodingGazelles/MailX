//
//  MxErrors.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// Mark: - UID

struct MxUID: Hashable, Equatable {
    var value: String
    init(){
        self.value = NSUUID().UUIDString
    }
    init(value: String){
        self.value = value
    }
    init(uid: MxUID){
        self.value = uid.value
    }
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxUID, rhs: MxUID) -> Bool{
    return lhs.value == rhs.value
}


// Mark: - Business object

enum MxBusinessObjectEnum {
    case Provider
    case Mailbox
    case Label
    case Message
}

protocol MxBusinessObjectType: Loggable {
    var UID: MxUID { get set }
    var hashValue: Int { get }
}

extension MxBusinessObjectType {
    var hashValue: Int {
        return UID.value.hashValue
    }
}

func ==<BO: MxBusinessObjectType>(lhs: BO, rhs: BO) -> Bool{
    return lhs.UID == rhs.UID
}


// Mark: - Error

protocol MxException: ErrorType, Loggable {}

enum MxError: MxException {
    
    // when data are incoherent or missing
    case DataInconsistent( object: MxBusinessObjectType?, message: String, rootError: ErrorType?)
    
    // when can continue processing
    case InternalStateIncoherent( operationName: String, message: String, rootError: ErrorType?)
    
    // when a func returns an exception
    case OperationDidThrow( operationName: String, message: String, rootError: ErrorType? )
    
    // when a func return is incoherent
    case UnexpectedReturn( operationName: String, message: String, rootError: ErrorType?)
    
    // when a call parameter is incoherent
    case UnexpectedParameter( operationName: String, message: String, rootError: ErrorType?)
}



