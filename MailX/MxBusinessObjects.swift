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
//    var mailboxes: NSSet { get }
    
}


// MARK: - Mailbox

protocol MxMailboxProtocol: MxBusinessObjectProtocol {
    
    var email: String? { get set }
    var name: String? { get set }
//    var messages: NSSet { get }
//    var labels: NSSet { get }
    
}


// MARK: - Label

protocol MxLabelProtocol: MxBusinessObjectProtocol {
    
    var code: String? { get set }
    var name: String? { get set }
    var ownerType: MxLabelOwnerType { get set }
//    var mailbox: MxMailboxProtocol? { get set }
//    var messages: NSSet { get }
    
}


// MARK: - Message

protocol MxMessageProtocol: MxBusinessObjectProtocol {
}





