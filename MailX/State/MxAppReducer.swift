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
        
        
        switch action {
        
        // MARK: StateActions
            
        case _ as MxSetStateAction:
            state = (action as! MxSetStateAction).state
        
            
        // MARK: Mailbox Actions
            
        case _ as MxSetMailboxesAction:
            
            
        // MARK: LabelsActions
            
        case _ as MxShowAllLabelsAction:
            state.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.All
            
        case _ as MxShowSelectedLabelsAction:
            state.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.Selection
            
        case _ as MsSetLabelsAction:
            
            
        // MARK: PropertiesActions
            
        case _ as MxSetPropertiesAction:
            state.propertiesState = (action as! MxSetPropertiesAction).properties
            
            
        // MARK: ErrorsActions
            
        case _ as MxAddErrorsAction:
            state.errorsState.errors.appendContentsOf( (action as! MxAddErrorsAction).errors)
            
            
        // MARK: Unknown actions
            
        default:
            let message = "Reducer received an unidentified action. Unable to treat it. action: \(action)"
            
            MxLog.error( message)
            state.errorsState.errors.appendContentsOf( [MxErrorSO(message: message)])
            
        }
        
        return state
    }
    
}