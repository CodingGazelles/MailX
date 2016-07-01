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
    
    var snippet: String? {
        get {
            return snippet_
        }
        set {
            self.snippet_ = newValue
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
