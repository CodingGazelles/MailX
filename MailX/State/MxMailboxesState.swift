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

typealias MxMailboxSOResult = Result<MxMailboxSO, MxErrorSO>

struct MxMailboxSO: MxStateObjectProtocol {
    
    var id: MxObjectId
    var email: String
    var name: String
    var connected: Bool
    
    init( id: MxObjectId, email: String, name: String, connected: Bool){
        self.id = id
        self.email = email
        self.name = name
        self.connected = connected
    }
    
}

extension MxMailboxSO: MxInitWithModel {
    init( model: MxMailboxModel){
        self.init(
            id: model.id
            , email: model.email
            , name: model.name
            , connected: model.connected)
    }
}









