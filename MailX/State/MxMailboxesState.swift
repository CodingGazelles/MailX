//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMailboxSO: MxStateObjectType {
    
    var UID: String
    var id: String
    var name: String
    var connected: Bool
    
    init(id: String, name: String, connected: Bool){
        self.init()
        self.id = id
        self.name = name
        self.connected = connected
    }
    
    init(mailboxSO: MxMailboxSO){
        self.init(dataObject: mailboxSO)
        self.init(
            id: mailboxSO.id,
            name: mailboxSO.name,
            connected: mailboxSO.connected)
    }
}

extension MxMailboxSO {
    init( mailboxModel: MxMailboxModel){
        self.init(dataObject: mailboxModel)
        self.init(
            id: mailboxModel.id.value
            , name: mailboxModel.name
            , connected: mailboxModel.connected)
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



