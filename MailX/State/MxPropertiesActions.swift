//
//  MxSetPropertiesAction.swift
//  MailX
//
//  Created by Tancrède on 5/19/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



struct MxSetPropertiesAction: MxAction {
    var properties = MxPropertiesState()
}

extension MxPropertiesState {
    
    static func readDefaultProperties() -> MxPropertiesState {
//        let defaultLabels = MxAppProperties.defaultProperties().defaultLabels()
        let defaultLabels = ["INBOX", "UNREAD"]
        return MxPropertiesState(labelShortListCodes: defaultLabels)
    }
}

