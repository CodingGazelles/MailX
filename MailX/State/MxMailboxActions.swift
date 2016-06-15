//
//  MxMailboxActions.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import BrightFutures



struct MxSetMailboxesAction: MxAction {
    var mailboxes: [MxMailboxSO]
    var errors: [MxErrorSO]
}


func dispatchSetMailboxesAction() {
    
    MxLog.debug("Dispatching SetMailboxesAction")
    
    
    let store = MxUIStateManager.defaultStore()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getAllMailboxes() {
        
    case let .Success( results):
        
        let mailboxes = results
            .map{ MxMailboxSO(
                internalId: $0.internalId,
                remoteId:  $0.remoteId,
                email: $0.email,
                name: $0.name,
                connected: $0.connected) }
        
        let action = MxSetMailboxesAction(mailboxes: mailboxes, errors: [MxErrorSO]())
        
        MxLog.debug("Dispatching action: \(action)")
        
        store.dispatch(action)
    
        
    case let .Failure( error):
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        
        MxLog.debug("Dispatching action: \(action)")
        
        store.dispatch(action)
        
    }
    
    
}









