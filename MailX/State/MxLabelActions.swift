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

let setLabelsActionCreator = { (state: MxAppState) -> MxAction in
    
    MxLog.debug("Processing func action creator setLabelsActionCreator")
    
    switch state.mailboxesState.mailboxSelection{
    case .All, .None:
        
        let systemLabels = MxAppProperties.defaultProperties().systemLabels()
        let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
            |> map{ MxLabelSO(
                UID: nil
                , remoteId: nil
                , code: $0
                , name: systemLabels.labelName( labelCode: $0)
                , ownerType: MxLabelOwnerType.SYSTEM.rawValue )!}
        
        let action = MxSetLabelsAction( labels: defaultLabels, errors: [MxErrorSO]())
        MxLog.debug("Returning action: \(action)")
        
        return action
        
    case .One(let selectedMailbox):
        
        let result = fetchMailboxDBO( mailboxUID: selectedMailbox.UID)
        
        switch result {
        case let .Success( mailboxDBO):
            
            let results = mailboxDBO.labels
                |> map(){ $0.toModel()}
            
            let errosSO = results
                |> filter(){ $0.error != nil }
                |> map(){ MxErrorSO( error: $0.error! )}

            let labelsSO = results
                |> filter(){ $0.value != nil}
                |> map(){ $0.value!.toSO() }
            
            let action = MxSetLabelsAction( labels: labelsSO, errors: errosSO)
            MxLog.debug("Returning action: \(action)")
            return action
            
        case let .Failure( error):
            
            let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
            MxLog.debug("Returning action: \(action)")
            return action
        }
        
    }
    
}



