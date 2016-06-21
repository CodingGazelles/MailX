//
//  MxProvider.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation
import CoreData



enum MxProviderCode: String {
    case GMAIL = "GMAIL"
    case YAHOO = "YAHOO"
}

class MxProvider: MxBaseManagedObject, MxProviderProtocol {

// Insert code here to add functionality to your managed object subclass
    
    static let modelName = "MxProvider"
    
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
    
    var code: String? {
        get {
            return code_
        }
        set {
            self.code_ = newValue
        }
    }
    
//    var mailboxes: NSSet {
//        return mailboxes_ ?? NSSet()
//    }

}
