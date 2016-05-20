//
//  MxMailboxActions.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes



struct MxSetMailboxesAction: MxAction {
    
    var allMailboxes: [MxMailbox]
    var selectedMailbox: MxMailbox
    
}


struct MxMailboxDBActionsFactory {
    
    let loadAllMailboxes = { (state: MxAppState, store: MxStateStore) -> MxAction in
        
        let db = MxStoreManager.defaultDb()
        switch  db.fetchMailboxes() {
        case let .Success( mailboxes):
            
            mailboxes
                |> map( MxMailbox($0))
            
            
            return MxSetMailboxesAction(allMailboxes: , selectedMailbox)
            
        case let .Failure( error):
            
            return MxAddErrorsAction( errors: [error])
        }
        
    }
}

extension MxMailbox {
    init( mailboxModel: MxMailboxModel){
        self.id = mailboxModel.id.value
        self.name = mailboxModel.id.value
    }
}

