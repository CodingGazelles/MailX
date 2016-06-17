//
//  MxMailbox.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData


class MxMailbox: MxBaseManagedObject, MxMailboxProtocol {

// Insert code here to add functionality to your managed object subclass
    
    static let modelName = "MxMailbox"
    
    var connected: Bool = false
    var proxy: MxMailboxProxy!
    
    
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
    
    var email: String? {
        get {
            return email_
        }
        set {
            self.email_ = newValue
        }
    }
    
    var name: String? {
        get {
            return name_
        }
        set {
            self.name_ = newValue
        }
    }
    
    var provider: MxProvider? {
        get {
            return provider_
        }
        set {
            self.provider_ = newValue
        }
    }
    
    var labels: Set<MxLabel> {
        get {
            return (labels_ ?? Set<MxLabel>()) as! Set<MxLabel>
        }
        set {
            self.labels_ = newValue
        }
    }
    
}
