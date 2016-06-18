//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - State Object

struct MxMailboxSO: MxStateObjectProtocol, MxMailboxProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var email: String?
    var name: String?
    var connected: Bool = false
    
    init(){}
    
    init( internalId: MxInternalId, remoteId: MxRemoteId, email: String?, name: String?, connected: Bool){
        self.internalId = internalId
        self.remoteId = remoteId
        self.email = email
        self.name = name
        self.connected = connected
    }
    
    
    init( model: MxMailbox){
        self.internalId = model.internalId
        self.remoteId = model.remoteId
        self.email = model.email
        self.name = model.name
        self.connected = model.connected
    }
    
}











