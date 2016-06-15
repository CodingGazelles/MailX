//
//  MxMessage.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData


class MxMessage: MxBaseManagedObject, MxMessageProtocol {

// Insert code here to add functionality to your managed object subclass
    
    static let modelName = "MxMessage"
    
    override var internalId: MxInternalId? {
        get {
            return internalId_ != nil ? MxInternalId(value: internalId_!) : nil
        }
        set {
            self.internalId_ = newValue?.value
        }
    }
    
    override var remoteId: MxRemoteId? {
        get {
            return remoteId_ != nil ? MxRemoteId(value: remoteId_) : nil
        }
        set {
            self.remoteId_ = newValue?.value
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
