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




// MARK: - Refresh Mailbox State

enum MxRefreshFrom {
    case Local
    case Remote
}

func dispatchRefreshAllMailboxesStateAction( from from: MxRefreshFrom = MxRefreshFrom.Local) {
    
    switch from {
        
    case .Local:
        
        _dispatchRefreshAllMailboxesSateAction()
        
    case .Remote:
        
        let uiState = MxUIStateManager.defaultState()
        let dataStack = MxDataStackManager.defaultStack()
        
        switch dataStack.getAllMailboxes() {
            
        case let .Success( mailboxes):
            
            for mailbox in mailboxes {
                
                // mailbox: MxMailboxSO( model: mailbox)
                dispatchRefreshMailboxStateAction( mailboxId: mailbox.internalId!, from: .Remote)
                
            }
            
        case let .Failure(error):
            
            MxLog.error( "Failed to load mailboxes", error: error)
            
            let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
            uiState.dispatch(action)
            
        }
        
        
    }
}

private func _dispatchRefreshAllMailboxesSateAction() {
    
    MxLog.debug("Dispatching RefreshAllMailboxesSateAction")
    
    
    let store = MxUIStateManager.defaultState()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getAllMailboxes() {
        
    case let .Success( results):
        
        for mailbox in results {
            
            _dispatchRefreshMailboxStateAction( mailboxId: mailbox.internalId!)
            
        }
        
    case let .Failure( error):
        
        MxLog.error( "Failed to load mailboxes", error: error)
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        store.dispatch(action)
        
    }
}

func dispatchRefreshMailboxStateAction( mailboxId mailboxId: MxInternalId, from: MxRefreshFrom = .Local) {
    
    let uiState = MxUIStateManager.defaultState()
    
    switch from {
        
    case .Local:
        _dispatchRefreshMailboxStateAction( mailboxId: mailboxId)
        
    case .Remote:
        
        let syncManager = MxSyncManager.defaultManager()
        
        syncManager.refreshMailboxData(mailboxId: mailboxId)
            
            .onSuccess {
                
                _dispatchRefreshMailboxStateAction( mailboxId: mailboxId)
                
            }
            
            .onFailure { error in
                
                MxLog.error( "Failed to refresh mailbox data \(mailboxId)", error: error)
                
                let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                uiState.dispatch(action)
                
        }
        
    }
}

private func _dispatchRefreshMailboxStateAction( mailboxId mailboxId: MxInternalId) {
    
    dispatchRefreshMailboxLabelsStateAction( mailboxId: mailboxId)
    //    dispatchRefreshMailboxMessagesStateAction(mailbox: <#T##MxMailbox#>)
    
}


private func dispatchRefreshMailboxLabelsStateAction( mailboxId mailboxId: MxInternalId) {
    
    MxLog.debug("Processing RefreshMailboxLabelsAction \(mailboxId)")
    
    let uiState = MxUIStateManager.defaultState()
    let stack = MxDataStackManager.defaultStack()
    
    
    switch stack.getMailbox(mailboxId: mailboxId) {
        
        
    case let .Success( result):
        
        
        var labels = Set<MxLabel>(result.labels_!.allObjects as! [MxLabel])
            .map{ MxLabelSO( model: $0) }
        
        
        if labels.count == 0 {
            
            let systemLabels = MxAppProperties.defaultProperties().systemLabels()
            let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
                .map{ code -> MxLabelSO in
                    
                    let labelCode = MxLabelCode( string: code)
                    
                    return MxLabelSO(
                        internalId: nil,
                        remoteId: nil,
                        code: labelCode,
                        name: systemLabels.labelName( labelCode: labelCode),
                        ownerType: MxLabelOwnerType.SYSTEM)}
            
            labels.appendContentsOf( defaultLabels)
            
        }
        
        
        let action = MxRefreshMailboxLabelsAction( labels: labels, errors: [MxErrorSO]())
        uiState.dispatch(action)
        
        
    case let .Failure( error):
        
        MxLog.error( "Failed to fetch mailbox \(mailboxId)")
        
        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        uiState.dispatch(action)
        
    }
    
}


private func dispatchRefreshMailboxMessagesStateAction( mailboxId mailboxId: MxInternalId) {
    
    MxLog.debug("Processing MxSetMessagesAction")
}






