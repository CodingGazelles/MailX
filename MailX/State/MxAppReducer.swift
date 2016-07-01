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
            
            let error = MxStateError.UnknownAction(
                action: nil,
                message: "Reducer received an unidentified action. Unable to treat it. \(action)")
            
            MxLog.error( "Reducer received an unidentified action. Unable to treat it. \(action)", error: error)
            
            state.errorsState.errors.appendContentsOf( [MxErrorSO( error: error)])
            
            return state
        }
        
        let mxAction = action as! MxAction
        
        switch mxAction {
        
        // MARK: StateActions
            
        case _ as MxSetStateAction:
            state = (mxAction as! MxSetStateAction).state
        
            
        // MARK: Mailbox List Actions
            
        case _ as MxSetMailboxListAction:
            
            var selectedMailbox = (mxAction as! MxSetMailboxListAction).selectedMailbox
            var selectedIndex = 0
            
            for mailbox in (mxAction as! MxSetMailboxListAction).mailboxes {
            
                var tabItem = MxTabItemState( tabItemType: .MAILBOX, mailboxState: MxMailboxState())
                
                tabItem.mailboxState?.mailbox = mailbox
                
                if mailbox == selectedMailbox! {
                    state.selectedTabitem = selectedIndex
                }
                
                state.tabList.append(tabItem)
                
            }
            
            state.errorsState.errors.appendContentsOf((mxAction as! MxSetMailboxListAction).errors )

            
            
        // MARK: Mailbox Actions
            
        case _ as MxShowAllLabelsAction:
            
            state.tabList[state.selectedTabitem].mailboxState!.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.All
            
        case _ as MxShowDefaultsLabelsAction:
            
            state.tabList[state.selectedTabitem].mailboxState!.labelsState.labelDisplay = MxLabelsState.MxLabelDisplay.Defaults
            
        case _ as MxRefreshMailboxLabelListAction:
            
            state.tabList[state.selectedTabitem].mailboxState!.labelsState.allLabels
                = (mxAction as! MxRefreshMailboxLabelListAction).labels
            
            state.tabList[state.selectedTabitem].mailboxState!.labelsState.defaultLabels
                = state.propertiesState.labelShortListCodes
            
        case _ as MxRefreshMailboxMessageListAction:
            
            state.tabList[state.selectedTabitem].mailboxState!.messagesState.
            
            
            
            
        // MARK: PropertiesActions
            
        case _ as MxSetPropertiesAction:
            
            state.propertiesState = (mxAction as! MxSetPropertiesAction).properties
            
            
        // MARK: ErrorsActions
            
        case _ as MxAddErrorsAction:
            
            state.errorsState.errors.appendContentsOf( (mxAction as! MxAddErrorsAction).errors)
            
            
        // MARK: Unknown actions
            
        default:
            
            let error = MxStateError.UnknownAction(
                action: mxAction, 
                message: "Reducer received an unidentified action. Unable to treat it. \(action)")
            
            MxLog.error( "Reducer received an unidentified action. Unable to treat it. \(action)", error: error)
            
            state.errorsState.errors.appendContentsOf( [MxErrorSO( error: error)])
            
        }
        
        return state
    }
    
}