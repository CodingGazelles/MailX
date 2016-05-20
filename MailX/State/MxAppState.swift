//
//  AppState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



// Markers

protocol MxStateType : StateType {}
protocol MxStateModelType: MxStateType {}


struct MxAppState: MxStateType {
    
    var mailboxState = MxMailboxState()
    var providerState = MxProviderState()
    var labelState = MxLabelState()
    var messageState = MxMessageState()
    var propertiesState = MxPropertiesState()
    
    // recorder
//    var navigationState = NavigationState()
    
}



