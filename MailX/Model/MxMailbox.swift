//
//  MxMailbox.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData


class MxMailbox: NSManagedObject, MxModelObjectProtocol, MxCoreMailboxProtocol {

// Insert code here to add functionality to your managed object subclass
    
    var connected: Bool = false
    var proxy: MxMailboxProxy!
    
    
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
    
//    var messages: NSSet {
//        return messages_ ?? NSSet()
//    }
//    
    var labels: Set<MxLabel> {
        return (labels_ ?? Set<MxLabel>()) as! Set<MxLabel>
    }
    
}
