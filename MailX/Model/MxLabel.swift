//
//  MxLabel.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData



// MARK: - MxLabel

class MxLabel: MxBaseManagedObject, MxLabelProtocol {

// Insert code here to add functionality to your managed object subclass
    
    static let modelName = "MxLabel"
    
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
    
    var name: String? {
        get {
            return name_
        }
        set {
            self.name_ = newValue
        }
    }
    
    var code: MxLabelCode {
        get {
            return MxLabelCode(string: code_)
        }
        set {
            self.code_ = newValue.toString()
        }
    }
    
    var ownerType: MxLabelOwnerType {
        get {
            return MxLabelOwnerType(rawValue: ownerType_ ?? MxLabelOwnerType.UNDEFINED.rawValue)!
        }
        set {
            self.ownerType_ = newValue.rawValue
        }
    }
    
    var mailbox: MxMailbox? {
        get {
            return mailbox_
        }
        set {
            self.mailbox_ = newValue
        }
    }
    
}


