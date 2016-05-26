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

let loadMailboxes = { (state: MxAppState, store: MxStateStore) -> MxAction in
    
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
        
        return MxSetMailboxesAction(mailboxes: mailboxes, errors: errors)
        
    case let .Failure(error):
        return MxAddErrorsAction(errors: [MxErrorSO(error: error)])
    }

}







