//
//  MxMailboxSetActions.swift
//  MailX
//
//  Created by Tancrède on 6/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - Actions

struct MxSetMailboxListAction: MxAction {
    var mailboxes: [MxMailboxSO]
    var selectedMailbox: MxMailboxSO?
    var errors: [MxErrorSO]
}


func dispatchSetMailboxListAction() {
    
    MxLog.debug("Dispatching SetMailboxesAction")
    
    
    let store = MxUIStateManager.defaultState()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getAllMailboxes() {
        
    case let .Success( results):
        
        
        let mailboxes = results
            .map{ MxMailboxSO( model: $0)}
        
        
        var selectedMailbox: MxMailboxSO?
        if mailboxes.count > 0 {
            selectedMailbox = mailboxes[0]
        }
        
        
        let action = MxSetMailboxListAction(
            mailboxes: mailboxes,
            selectedMailbox: selectedMailbox,
            errors: [MxErrorSO]())
        
        
        store.dispatch(action)
        
        
    case let .Failure( error):
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        store.dispatch(action)
        
    }
    
}