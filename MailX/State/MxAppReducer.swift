//
//  MxAppReducer.swift
//  MailX
//
//  Created by Tancrède on 5/18/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



struct MxAppReducer: Reducer {
    
    func handleAction( action: Action, state: MxAppState?) -> MxAppState {
        var state = state ?? MxAppState()
        
        guard action is MxAction else {
            
            let error = MxStateError.UnknownAction(action: nil, message: "Reducer received an unidentified action. Unable to treat it. \(action)")
            
            MxLog.error( "Reducer received an unidentified action. Unable to treat it. \(action)", error: error)
            
            state.errorsState.errors.appendContentsOf( [MxErrorSO( error: error)])
            
            return state
        }
        
        let mxAction = action as! MxAction
        
        switch mxAction {
        
        // MARK: StateActions
            
        case _ as MxSetStateAction:
            state = (mxAction as! MxSetStateAction).state
        
            
        // MARK: Mailbox Actions
            
        case _ as MxSetMailboxesAction:
            state.mailboxesState.allMailboxes = (mxAction as! MxSetMailboxesAction).mailboxes
            
        // MARK: LabelsActions
            
        case _ as MxShowAllLabelsAction:
            state.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.All
            
        case _ as MxShowDefaultsLabelsAction:
            state.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.Defaults
            
        case _ as MxSetLabelsAction:
            state.labelsState.allLabels = (mxAction as! MxSetLabelsAction).labels
            state.labelsState.defaultLabels = state.propertiesState.labelShortListCodes
            
            
        // MARK: PropertiesActions
            
        case _ as MxSetPropertiesAction:
            state.propertiesState = (mxAction as! MxSetPropertiesAction).properties
            
            
        // MARK: ErrorsActions
            
        case _ as MxAddErrorsAction:
            state.errorsState.errors.appendContentsOf( (mxAction as! MxAddErrorsAction).errors)
            
            
        // MARK: Unknown actions
            
        default:
            
            let error = MxStateError.UnknownAction(action: mxAction, message: "Reducer received an unidentified action. Unable to treat it.")
            
            MxLog.error( "Reducer received an unidentified action. Unable to treat it.", error: error)
            
            state.errorsState.errors.appendContentsOf( [MxErrorSO( error: error)])
            
        }
        
        return state
    }
    
}