//
//  MxMessageActions.swift
//  MailX
//
//  Created by Tancrède on 6/12/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxSetMessagesAction: MxAction {
    var messages: [MxMessageSO]
    var errors: [MxErrorSO]
}

func dispatchSetMessagesAction() {
    
    MxLog.debug("Processing MxSetMessagesAction")
}