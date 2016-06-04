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

struct MxMailboxSO: MxStateObjectType {
    
    var UID: MxUID
    var remoteId: String?
    var name: String
    var connected: Bool
    
    init(UID: MxUID?, remoteId: String?, name: String, connected: Bool){
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.name = name
        self.connected = connected
    }
    
    init(mailboxSO: MxMailboxSO){
        self.init(
            UID: mailboxSO.UID
            , remoteId: mailboxSO.remoteId
            , name: mailboxSO.name
            , connected: mailboxSO.connected)
    }
}

extension MxMailboxSO: MxInitWithModel {
    init( model: MxMailboxModel){
        self.init(
            UID: model.UID
            , remoteId: model.remoteId?.value
            , name: model.name
            , connected: model.connected)
    }
}

func toSO( mailbox mailbox: Result<MxMailboxModel, MxModelError> ) -> MxMailboxSOResult {
    switch mailbox {
    case let .Success(model):
        return Result.Success( MxMailboxSO(model: model))
    case let .Failure( error):
        return Result.Failure( errorSO(error: error))
    }
}


// MARK: - State

struct MxMailboxesState: MxStateType {
    
    var allMailboxes = [MxMailboxSO]()
    var mailboxSelection = MxMailboxSelection.None
    
    enum MxMailboxSelection {
        case All
        case One(MxMailboxSO)
        case None
    }
    
    func selectedMailbox() -> [MxMailboxSO]{
        switch mailboxSelection {
        case .All:
            return allMailboxes
        case .None:
            return []
        case .One(let selectedMailbox):
            return [selectedMailbox]
        }
    }
    
}



