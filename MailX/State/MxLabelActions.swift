//
//  MxLabelActions.swift
//  MailX
//
//  Created by Tancrède on 5/18/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import BrightFutures



// MARK: - Actions

struct MxShowAllLabelsAction: MxAction {}

struct MxShowDefaultsLabelsAction: MxAction {}

struct MxSelectLabelAction: MxAction {
    var selectedLabelCode: String
}

struct MxSetLabelsAction: MxAction {
    var labels: [MxLabelSO]
    var errors: [MxErrorSO]
}


// MARK: - Actions creators

func dispatchSetLabelsAction() {
    
    MxLog.debug("Processing MxSetLabelsAction")
    
    let store = MxUIStateManager.defaultStore()
    let stack = MxDataStackManager.defaultStack()
    
    store.dispatch( MxStartLoadingAction())
    
    switch store.state.mailboxesState.mailboxSelection {
    case .All, .None:
        
        let systemLabels = MxAppProperties.defaultProperties().systemLabels()
        let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
            .map{ MxLabelSO(
                internalId: nil,
                remoteId: nil,
                code: $0,
                name: systemLabels.labelName( labelCode: $0),
                ownerType: MxLabelOwnerType.SYSTEM)}
        
        let action = MxSetLabelsAction( labels: defaultLabels, errors: [MxErrorSO]())
        
        MxLog.debug("Dispatching action: \(action)")
        
        store.dispatch(action)
        
    case .One(let selectedMailbox):
        
        switch stack.getMailbox(mailboxId: selectedMailbox.internalId!) {
        case let .Success( result):
            
            let labels = Set<MxLabel>(result.labels_!.allObjects as! [MxLabel])
                .map{ MxLabelSO(
                    internalId: $0.internalId,
                    remoteId: $0.remoteId,
                    code: $0.code,
                    name: $0.name,
                    ownerType: $0.ownerType) }
            
            let action = MxSetLabelsAction( labels: labels, errors: [MxErrorSO]())
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
        case let .Failure( error):
            
            let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
            
            MxLog.debug("Dispatching action: \(action)")
            
            store.dispatch(action)
            
        }
        
        
    }
    
}



