//
//  MxMessage.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData


class MxMessage: NSManagedObject, MxModelObjectProtocol, MxCoreMessageProtocol {

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
    
//    var labels: NSSet {
//        return labels_ ?? NSSet()
//    }
//    
//    var mailbox: MxMailboxProtocol? {
//        get {
//            return mailbox_ != nil ? (mailbox_ as! MxMailboxProtocol) : nil
//        }
//        set {
//            self.mailbox_ = newValue != nil ? (newValue as! MxMailbox) : nil
//        }
//    }
    
}
