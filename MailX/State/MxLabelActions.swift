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



struct MxShowAllLabelsAction: MxAction {}

struct MxShowSelectedLabelsAction: MxAction {}

struct MxSelectLabelAction: MxAction {
    var selectedLabelCode: String
}

struct MxSetLabelsAction: MxAction {
    var labels: [MxLabelSO]
    var errors: [MxErrorSO]
}

let loadLabels = { (state: MxAppState) -> MxAction in
    
    switch state.mailboxesState.mailboxSelection{
    case .All, .None:
        
        let systemLabels = MxAppProperties.defaultProperties().systemLabels()
        let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
            |> map{ MxLabelSO(
                UID: nil
                , id: nil
                , code: $0
                , name: systemLabels.labelName( labelCode: $0)
                , ownerType: MxLabelOwnerType.SYSTEM.rawValue )!}
        
        return MxSetLabelsAction( labels: defaultLabels, errors: [MxErrorSO]())
        
    case .One(let selectedMailbox):
        
        let result = fetchMailboxDBO( mailboxId: selectedMailbox.id)
            |> { $0.labels}
            |> map(){toModel(label: $0)}
            |> map(){toSO(label: $0)}
        
        switch result {
        case let .Success( value):
            
            let results: [MxLabelSOResult] = value
            
            let errosSO = results
                |> filter(){ $0.error != nil }
                |> map(){ $0.error!}
            
            let labelsSO = results
                |> filter(){ $0.value != nil}
                |> map(){ $0.value! }
            
            return MxSetLabelsAction( labels: labelsSO, errors: errosSO)
            
        case let .Failure( error):
            return MxAddErrorsAction(errors: [MxErrorSO(error: error)])
        }
        
    }
    
}



