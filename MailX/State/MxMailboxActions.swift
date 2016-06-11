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
    
    
    let store = MxStateManager.defaultStore()
    let stack = MxStackManager.sharedInstance()
    
    
    store.dispatch( MxStartLoadingAction())
    
    
    let _: Future<[MxMailboxModel],MxStackError> = stack.getAllObjects()
        
        .andThen() {_ in
            
            store.dispatch( MxStopLoadingAction())
            
        }
        
        .onSuccess(){ results in
            
            let mailboxes = results
                .map{ MxMailboxSO(model: $0 ) }
            
            let action = MxSetMailboxesAction(mailboxes: mailboxes, errors: [MxErrorSO]())
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
        }
        
        .onFailure() { error in
            
            let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
    }
    
    
}









