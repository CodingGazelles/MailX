//
//  MxFetchMessagesInLabelTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchMessagesInLabelCompletionHandler = (messages: [MxMessageModel]?, error: MxBridgeError?) -> Void


class MxFetchMessagesInLabelOperation : MxSyncOperation {
    
    var completionHandler: MxFetchMessagesInLabelCompletionHandler
    var labelId: MxLabelModel.Id
    
    init( labelId: MxLabelModel.Id, bridge: MxMailboxBridge, completionHandler: MxFetchMessagesInLabelCompletionHandler) {
        
        self.completionHandler = completionHandler
        self.labelId = labelId
        super.init( bridge: bridge)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) fetch messages ticket sending request to mailbox: \(bridge.mailbox.email)")
        
        bridge.sendFetchMessagesInLabelRequest( labelId: labelId, completionHandler: proxyDidFetchMessagesInLabel)
        
    }
    
    func proxyDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: MxBridgeError?) {
        
        MxLog.debug("\(#function) fetch messages ticket received response of mailbox: \(bridge.mailbox.email)")
        
        state = .Finished
        completionHandler( messages: messages, error: error)
        
    }
}


