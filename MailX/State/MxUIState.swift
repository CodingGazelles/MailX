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
    
//    var mailboxList = [MxMailboxSO:MxMailboxState]()
//    var selectedMailbox: MxMailboxSO?
    
    var tabList = [MxTabItemState]()
    var selectedTabitem = 0
    
    func selectedTab() -> MxTabItemState {
        
    }
    
    func tabItemForEmail( email: String) -> MxTabItemState {
        return tabList.filter{ $0.mailboxState?.mailbox.email == email }[0]
    }
    
    var propertiesState = MxPropertiesState()
    var errorsState = MxErrorsState()
    
    // recorder
//    var navigationState = NavigationState()
    
}

enum MxTabItemType {
    case MAILBOX
    case MAIL_READER
    case MAIL_EDITOR
}

struct MxTabItemState: MxStateType {
    var tabItemType = MxTabItemType.MAILBOX
    var mailboxState: MxMailboxState?
}

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
                |> filter{ (label: MxLabelSO) -> Bool in
                    return self.defaultLabels.contains( label.code.toString())
            }
        }
    }
    
    func showAllLabels() -> Bool {
        return labelDisplay == .All
    }
    
}

struct MxMessageState: MxStateType {
    
    var allMessages = [MxMessageSO]()
    
    func visibleMessages() -> [MxMessageSO] {
        return allMessages
            |> filter { (message: MxMessageSO) -> Bool in
                return message.
        }
    }
}

struct MxPropertiesState: MxStateType {
    var labelShortListCodes = [String]()
}

struct MxErrorsState: MxStateType {
    var errors = [MxErrorSO]()
}



