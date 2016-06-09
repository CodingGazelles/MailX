//
//  MxLabelActions.swift
//  MailX
//
//  Created by Tancrède on 5/18/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift
import Pipes
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
    var errors: [MxSOError]
}


// MARK: - Actions creators

func dispatchSetLabelsAction() {
    
    MxLog.debug("Processing MxSetLabelsAction")
    
    let store = MxStoreManager.defaultStore()
    let stack = MxStackManager.sharedInstance()
    
    store.dispatch( MxStartLoadingAction())
    
    switch store.state.mailboxesState.mailboxSelection {
    case .All, .None:
        
        let systemLabels = MxAppProperties.defaultProperties().systemLabels()
        let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
            .map{ MxLabelSO(
                id: MxObjectId()
                , code: $0
                , name: systemLabels.labelName( labelCode: $0)
                , ownerType: MxLabelOwnerType.SYSTEM.rawValue
                , mailboxId: MxObjectId())!}
        
        let action = MxSetLabelsAction( labels: defaultLabels, errors: [MxSOError]())
        
        MxLog.debug("Dispatching action: \(action)")
        
        store.dispatch(action)
        
    case .One(let selectedMailbox):
        
        let _: Future<[Result<MxLabelModel,MxStackError>],MxStackError> = stack.getAllObjects()
        
            .andThen( context: Queue.main.context) {_ in
                
                store.dispatch( MxStopLoadingAction())
                
        }
        
            .onSuccess( Queue.main.context) { results in
                
                let errors = results
                    .filter{ $0.error != nil }
                    .map{ MxSOError( error: $0.error!) }
                
                let labels = results
                    .filter{ $0.value != nil }
                    .map{ $0.value! }
                    .filter{ $0.mailboxId == selectedMailbox.id }
                    .map{ MxLabelSO( model: $0) }
                
                let action = MxSetLabelsAction( labels: labels, errors: errors)
                
                MxLog.debug("Dispatching action: \(action)")
                
                store.dispatch(action)
                
        }
        
            .onFailure( Queue.main.context) { error in
                
                let action = MxAddErrorsAction(errors: [MxSOError(error: error)])
                
                MxLog.debug("Dispatching action: \(action)")
                
                store.dispatch(action)
                
        }
        
//        let result = fetchMailboxDBO( mailboxUID: selectedMailbox.UID)
        
//        switch result {
//        case let .Success( mailboxDBO):
//            
//            let results = mailboxDBO.labels
//                |> map(){ $0.toModel()}
//            
//            let errosSO = results
//                |> filter(){ $0.error != nil }
//                |> map(){ MxSOError( error: $0.error! )}
//
//            let labelsSO = results
//                |> filter(){ $0.value != nil}
//                |> map(){ $0.value!.toSO() }
//            
//            let action = MxSetLabelsAction( labels: labelsSO, errors: errosSO)
//            MxLog.debug("Returning action: \(action)")
//            return action
//            
//        case let .Failure( error):
//            
//            let action = MxAddErrorsAction(errors: [MxSOError(error: error)])
//            MxLog.debug("Returning action: \(action)")
//            return action
//        }
        
    }
    
}



