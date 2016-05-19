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
        case _ as MxShowAllLabelsAction:
            state.labelState.labelDisplay = MxLabelState.MxLabelDisplay.All
            break
        case _ as MxShowSelectedLabelsAction:
            state.labelState.labelDisplay = MxLabelState.MxLabelDisplay.Selection(labelIdArray: <#T##[String]#>)
            break
        }
        
        return state
    }
    
}