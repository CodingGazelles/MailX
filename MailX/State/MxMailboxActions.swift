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
import BrightFutures



struct MxSetMailboxesAction: MxAction {
    var mailboxes: [MxMailboxSO]
    var errors: [MxSOError]
}


func dispatchSetMailboxesAction() {
    
    MxLog.debug("Dispatching SetMailboxesAction")
    
    
    let store = MxStoreManager.defaultStore()
    let stack = MxStackManager.sharedInstance()
    
    
    store.dispatch( MxStartLoadingAction())
    
    
    let _: Future<[Result<MxMailboxModel,MxStackError>],MxStackError> = stack.getAllObjects()
        
        .andThen( context: Queue.main.context) {_ in
            
            store.dispatch( MxStopLoadingAction())
            
        }
        
        .onSuccess( Queue.main.context){ results in
            
            
            let errors = results
                .filter(){ $0.error != nil }
                .map{ MxSOError( error: $0.error!) }
            
            
            let mailboxes = results
                .filter(){ $0.value != nil }
                .map{ MxMailboxSO(model: $0.value! ) }
            
            
            let action = MxSetMailboxesAction(mailboxes: mailboxes, errors: errors)
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
        }
        
        .onFailure( Queue.main.context) { error in
            
            let action = MxAddErrorsAction(errors: [MxSOError(error: error)])
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
    }
    
    
}









