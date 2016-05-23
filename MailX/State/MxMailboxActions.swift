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
    var allMailboxes: [MxMailboxSO]
    var selectedMailbox: MxMailboxSO?
}

let loadAllMailboxes = { (state: MxAppState, store: MxStateStore) -> MxAction in
    
    switch MxPersistenceManager.defaultManager() {
    case let .Success( db):
        
        switch  db.fetchMailboxes() {
        case let .Success( mailboxModels):
            
            let mailboxes = mailboxModels
                |> map({ MxMailboxSO(mailboxModel: $0)})
            
            return MxSetMailboxesAction(allMailboxes: mailboxes, selectedMailbox: mailboxes[0] ?? nil)
            
        case let .Failure( error):
            MxLog.error("Error while fetching mailboxes from DB", error: error)
            return MxAddErrorsAction( errors: [MxErrorSO( error: error)])
        }
        
    case let .Failure(error):
        MxLog.error("Error while initializinf Persistence Manager", error: error)
        return MxAddErrorsAction( errors: [MxErrorSO( error: error)])
    }
}







