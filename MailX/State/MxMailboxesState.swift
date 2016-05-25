//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



struct MxMailboxSO: MxStateObjectType {
    
    var UID: MxUID
    var id: String
    var name: String
    var connected: Bool
    
    init(UID: MxUID?, id: String, name: String, connected: Bool){
        self.init(UID: UID)
        self.id = id
        self.name = name
        self.connected = connected
    }
    
    init(mailboxSO: MxMailboxSO){
        self.init(
            UID: mailboxSO.UID
            , id: mailboxSO.id
            , name: mailboxSO.name
            , connected: mailboxSO.connected)
    }
}

extension MxMailboxSO: MxInitWithModel {
    init( model: MxMailboxModel){
        self.init(
            UID: model.UID
            , id: model.id.value
            , name: model.name
            , connected: model.connected)
    }
}

typealias MxMailboxSOResult = Result<MxMailboxSO, MxDBError>

func toSO( model model: MxMailboxModelResult) -> MxMailboxSOResult {
    switch model {
    case let .Success(model):
        return Result.Success( MxMailboxSO(model: model))
    case let .Failure( error):
        return Result.Failure(error)
    }
}

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



