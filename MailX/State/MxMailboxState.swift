//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMailbox: MxStateType {
    var id: String
    var name: String
    var connected: Bool
}

struct MxMailboxState: MxStateType {
    
    var allMailboxes = [MxMailbox]()
    var mailboxSelection = MxMailboxSelection.None
    
    enum MxMailboxSelection {
        case All
        case One(MxMailbox)
        case None
    }
    
    func selectedMailbox() -> [MxMailbox]{
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



