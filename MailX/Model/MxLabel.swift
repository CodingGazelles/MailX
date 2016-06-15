//
//  MxLabel.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData



class MxLabel: NSManagedObject, MxModelObjectProtocol, MxCoreLabelProtocol {

// Insert code here to add functionality to your managed object subclass
    
    var internalId: MxInternalId? {
        get {
            return internal_id != nil ? MxInternalId(value: internal_id!) : nil
        }
        set {
            self.internal_id = newValue?.value
        }
    }
    
    var remoteId: MxRemoteId? {
        get {
            return remote_id != nil ? MxRemoteId(value: remote_id) : nil
        }
        set {
            self.remote_id = newValue?.value
        }
    }
    
    var ownerType: MxLabelOwnerType {
        get {
            return MxLabelOwnerType(rawValue: owner_type ?? MxLabelOwnerType.UNDEFINED.rawValue)!
        }
        set {
            self.owner_type = newValue.rawValue
        }
    }
    
//    var mailbox: MxMailboxProtocol? {
//        get {
//            return mailbox_ != nil ? (mailbox_ as! MxMailboxProtocol) : nil
//        }
//        set {
//            self.mailbox_ = newValue != nil ? (newValue as! MxMailbox) : nil
//        }
//    }
//    
//    var messages: NSSet {
//        return messages_ ?? NSSet()
//    }
    
}

enum MxLabelOwnerType: String {
    case SYSTEM = "SYSTEM"
    case USER = "USER"
    case UNDEFINED = "UNDEFINED"
}
