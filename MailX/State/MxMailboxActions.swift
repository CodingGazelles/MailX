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



// MARK: - Actions

struct MxRefreshMailboxLabelsAction: MxAction {
    var labels: [MxLabelSO]
    var errors: [MxErrorSO]
}

struct MxRefreshMailboxMessagesAction: MxAction {
    var messages: [MxMessageSO]
    var errors: [MxErrorSO]
}

struct MxShowAllLabelsAction: MxAction {}

struct MxShowDefaultsLabelsAction: MxAction {}

struct MxSelectLabelAction: MxAction {
    var selectedLabelCode: String
}




// MARK: - Actions creators

func dispatchRefreshAllMailboxesAction() {
    
    MxLog.debug("Dispatching SetMailboxesDataAction")
    
    
    let store = MxUIStateManager.defaultState()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getAllMailboxes() {
        
    case let .Success( results):
        
        for mailbox in results {
            
            dispatchRefreshMailboxAction( mailbox: MxMailboxSO( model: mailbox))
            
        }
        
    case let .Failure( error):
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        store.dispatch(action)
        
    }
}

func dispatchRefreshMailboxAction( mailbox mailbox: MxMailboxSO) {
    
    dispatchRefreshMailboxLabelsAction( mailbox: mailbox)
    //    dispatchRefreshMailboxMessagesAction(mailbox: <#T##MxMailbox#>)
    
}


func dispatchRefreshMailboxLabelsAction( mailbox mailbox: MxMailboxSO) {
    
    MxLog.debug("Processing RefreshMailboxLabelsAction \(mailbox.email)")
    
    let uiState = MxUIStateManager.defaultState()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getMailbox(mailboxId: mailbox.internalId!) {
        
        
    case let .Success( result):
        
        
        var labels = Set<MxLabel>(result.labels_!.allObjects as! [MxLabel])
            .map{ MxLabelSO( model: $0) }
        
        
        if labels.count == 0 {
            
            let systemLabels = MxAppProperties.defaultProperties().systemLabels()
            let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
                        .map{ MxLabelSO(
                            internalId: nil,
                            remoteId: nil,
                            code: $0,
                            name: systemLabels.labelName( labelCode: $0),
                            ownerType: MxLabelOwnerType.SYSTEM)}
            
            labels.appendContentsOf( defaultLabels)
            
        }
        
        
        let action = MxRefreshMailboxLabelsAction( labels: labels, errors: [MxErrorSO]())
        uiState.dispatch(action)
        
        
    case let .Failure( error):
        
        MxLog.error( "Failed to fetch mailbox \(mailbox.email)")
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        uiState.dispatch(action)
        
    }
    
}


func dispatchRefreshMailboxMessagesAction( mailbox mailbox: MxMailboxSO) {
    
    MxLog.debug("Processing MxSetMessagesAction")
}






