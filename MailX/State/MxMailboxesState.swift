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

//typealias MxMailboxSOResult = Result<MxMailboxSO, MxErrorSO>

struct MxMailboxSO: MxStateObjectProtocol, MxCoreMailboxProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var email: String?
    var name: String?
    var connected: Bool = false
    
}

extension MxMailboxSO: MxInitWithModel {
    init( model: MxMailbox){
        self.init(
            internalId: model.internalId,
            remoteId: model.remoteId,
            email: model.email,
            name: model.name,
            connected: model.connected)
    }
}









