//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



// MARK: - State Object

struct MxMailboxSO: MxStateObjectProtocol, MxMailboxProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var email: String?
    var name: String?
    var connected: Bool = false
    
}











