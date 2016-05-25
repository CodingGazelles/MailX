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
    
    let results = fetchMailboxes()
        |> map({toSO(mailbox: $0)})

    switch results {
    case let .Success(soResultArray):
        
        let mailboxes = results
            |> filter(){ $0.value != nil}
            |> map(){ $0.value! }
//            |> { $0.value! }
        
        let errors = results
            |> filter(){ $0.error != nil}
            |> map(){ $0.error!}
            |> map(){ errorSO(errorDBO: $0)}
//            |> { $0.value! }
        
        return MxSetMailboxesAction(mailboxes: mailboxes, errors: errors)
        
    case let .Failure(error):
        return MxAddErrorsAction(errors: [MxErrorSO(error: error)])
    }

}







