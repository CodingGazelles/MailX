//
//  AppState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



struct MxAppState: StateType {
    
    var mailboxState = MxMailboxState()
    var providerState = MxProviderState()
    var labelState = MxLabelState()
    var messageState = MxMessageState()
    
    // recorder
//    var navigationState = NavigationState()
    
}



