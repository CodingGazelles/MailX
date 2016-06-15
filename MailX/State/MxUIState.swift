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
    
    var mailboxesState = MxMailboxesState()
    var providersState = MxProvidersState()
    var labelsState = MxLabelsState()
    var messagesState = MxMessageState()
    var propertiesState = MxPropertiesState()
    var errorsState = MxErrorsState()
    
    // recorder
//    var navigationState = NavigationState()
    
}

struct MxProvidersState: MxStateType {
    var providers = [MxProviderSO]()
}

struct MxMailboxesState: MxStateType {
    
    var allMailboxes = [MxMailboxSO]()
    var mailboxSelection = MxMailboxSelection.None
    
    enum MxMailboxSelection {
        case All
        case One(MxMailboxSO)
        case None
    }
    
    func selectedMailbox() -> [MxMailboxSO]{
        switch mailboxSelection {
        case .All:
            return allMailboxes
        case .None:
            return []
        case .One(let selectedMailbox):
            return [selectedMailbox]
        }
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



