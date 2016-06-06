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
    var mailboxes: [MxMailboxSO]
    var errors: [MxSOError]
}


func dispatchSetMailboxesAction() {
    
    MxLog.debug("\(dispatchSetMailboxesAction): dispatching SetMailboxesAction")
    
    
    let state = MxStateManager.defaultState()
    let stack = MxPersistenceStackManager.sharedInstance()
    
    
    state.dispatch( MxStartLoadingAction())
    
    let queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    dispatch_async( queue, {
        
        stack.getAllObjects(objectType: MxMailboxModel.self) { result in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                switch result {
                case let .Success(results):
                    
                    let errors = results
                        .filter(){ $0.error != nil }
                        .map(){ MxSOError( error: $0.error!) }
                    
                    let mailboxes = results
                        .filter(){ $0.value != nil }
                        .map(){ MxMailboxSO(model: $0.value! as! MxMailboxModel ) }
                    
                    let action = MxSetMailboxesAction(mailboxes: mailboxes, errors: errors)
                    MxLog.debug("Dispatching action: \(action)")
                    
                    state.dispatch(action)
                    
                case let .Failure(error):
                    
                    let action = MxAddErrorsAction(errors: [MxSOError(error: error)])
                    MxLog.debug("Dispatching action: \(action)")
                    
                    state.dispatch(action)
                    
                }
                
                state.dispatch( MxStopLoadingAction())
                
            }
        }
    })
}









