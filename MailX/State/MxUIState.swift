//
//  AppState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift
import Pipes



// MARK: - State

protocol MxStateType : ReSwift.StateType, Loggable {}

struct MxAppState: MxStateType {
    
    var mailboxList = [MxMailboxSO:MxMailboxState]()
    var selectedMailbox: MxMailboxSO?
    
    var propertiesState = MxPropertiesState()
    var errorsState = MxErrorsState()
    
    // recorder
//    var navigationState = NavigationState()
    
}

//struct MxProvidersState: MxStateType {
//    var providers = [MxProviderSO]()
//}

struct MxMailboxState: MxStateType {
    
    var mailbox = MxMailboxSO()
    var labelsState = MxLabelsState()
    var messagesState = MxMessageState()
    
//    var statusState = MxMailboxStatusState() TODO
    
    func refreshMailbox() {
        
    }
}

struct MxLabelsState: MxStateType {
    
    var allLabels = [MxLabelSO]()
    var labelDisplay = MxLabelDisplay.Defaults
    var defaultLabels = [String]()
    
    enum MxLabelDisplay {
        case All
        case Defaults
    }
    
    func visibleLabels() -> [MxLabelSO] {
        switch labelDisplay {
        case .All:
            return allLabels
        default:
            return allLabels
                |> filter(){ self.defaultLabels.contains($0.code!)}
        }
    }
    
    func showAllLabels() -> Bool {
        return labelDisplay == .All
    }
    
}

struct MxMessageState: MxStateType {
//    var messages = [MxMessageRow]()
}

struct MxPropertiesState: MxStateType {
    var labelShortListCodes = [String]()
}

struct MxErrorsState: MxStateType {
    var errors = [MxErrorSO]()
}



