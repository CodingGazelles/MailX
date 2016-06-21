//
//  MxErrors.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - Business Objects

protocol MxBusinessObjectProtocol: Loggable, Hashable, Equatable {
    var internalId: MxInternalId? { get set }
    var remoteId: MxRemoteId? { get set }
}

extension MxBusinessObjectProtocol {
    var hashValue: Int {
        return remoteId?.hashValue ?? "".hashValue
    }
}

func ==<T: MxBusinessObjectProtocol>(lhs: T, rhs: T) -> Bool{
    return lhs.remoteId?.value == rhs.remoteId?.value
}


// MARK: - Provider

protocol MxProviderProtocol: MxBusinessObjectProtocol {
    var code: String? { get set }
    var name: String? { get set }
}


// MARK: - Mailbox

protocol MxMailboxProtocol: MxBusinessObjectProtocol {
    var email: String? { get set }
    var name: String? { get set }
}


// MARK: - Label

protocol MxLabelProtocol: MxBusinessObjectProtocol {
    var code: MxLabelCode { get set }
    var name: String? { get set }
    var ownerType: MxLabelOwnerType { get set }
}

enum MxLabelCode: Equatable {
    
    case SYSTEM( MxSystemLabelCode)
    case USER( String)
    
    init( string: String?) {
        
        guard string != nil else {
            self = MxLabelCode.USER("NIL")
            return
        }
        
        let systemCode = MxSystemLabelCode(rawValue: string!)
        
        guard systemCode != nil else {
            self = MxLabelCode.USER(string!)
            return
        }
        
        self = MxLabelCode.SYSTEM(systemCode!)
        
    }
    
    func toString() -> String? {
        
        switch self {
            
        case let .SYSTEM( systemCode):
            return systemCode.rawValue
            
        case let .USER( userCode):
            return userCode
        }
        
    }

}

func ==(lhs: MxLabelCode, rhs: MxLabelCode) -> Bool{
    switch (lhs, rhs) {
    case ( let .SYSTEM( sysCode1), let .SYSTEM(sysCode2)):
        return sysCode1 == sysCode2
    case (let .USER( usrCode1), let .USER( usrCode2)):
        return usrCode1 == usrCode2
    default:
        return false
    }
}

enum MxSystemLabelCode: String {
    case INBOX = "INBOX"
    case UNREAD = "UNREAD"
    case STARRED = "STARRED"
    case ALL = "ALL"
    case SENT = "SENT"
    case TRASH = "TRASH"
    case SPAM = "SPAM"
    case DRAFT = "DRAFT"
    case OUTBOX = "OUTBOX"
}

enum MxLabelOwnerType: String {
    case SYSTEM = "SYSTEM"
    case USER = "USER"
    case UNDEFINED = "UNDEFINED"
}

func labelName( labelCode labelCode: MxLabelCode) -> String? {
    return MxAppProperties.defaultProperties().systemLabels().labelName(labelCode: labelCode)
}

func labelProviderCode( labelCode labelCode: MxLabelCode, providerCode: MxProviderCode) -> String? {
    return MxAppProperties.defaultProperties().provider(providerCode: providerCode)?.labelProviderCode(labelCode: labelCode)
}


// MARK: - Message

protocol MxMessageProtocol: MxBusinessObjectProtocol {
}





