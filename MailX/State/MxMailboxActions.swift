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
    var errors: [MxErrorSO]
}

let setMailboxesActionCreator = { (state: MxAppState) -> MxAction in
    
    MxLog.debug("Processing func action creator setMailboxesActionCreator")
    
    let result = fetchMailboxes()
        |> map({toSO(mailbox: $0)})

    switch result {
    case let .Success(value):
        
        let results: [MxMailboxSOResult] = value
        
        let mailboxes = results
            |> filter(){ $0.value != nil}
            |> map(){ $0.value! }
        
        let errors = results
            |> filter(){ $0.error != nil}
            |> map(){ $0.error!}
        
        let action = MxSetMailboxesAction(mailboxes: mailboxes, errors: errors)
        MxLog.debug("Returning action: \(action)")
        
        return action
        
    case let .Failure(error):
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        MxLog.debug("Returning action: \(action)")
        
        return action
    }

}







