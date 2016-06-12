//
//  MxFetchMessagesInLabelTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchMessagesCallback = (messages: [MxMessageModel]?, error: MxBridgeError?) -> Void


class MxFetchMessagesCommand : MxNetworkCommand {
    
    var callback: MxFetchMessagesCallback
    var labelId: MxObjectId
    
    init( labelId: MxObjectId, adapter: MxMailboxAdapter, callback: MxFetchMessagesCallback) {
        
        self.callback = callback
        self.labelId = labelId
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) fetch messages ticket sending request to mailbox: \(adapter.mailbox.email)")
        
        adapter.sendFetchMessagesRequest( labelId: labelId, callback: proxyDidFetchMessagesInLabel)
        
    }
    
    func proxyDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: MxBridgeError?) {
        
        MxLog.debug("\(#function) fetch messages ticket received response of mailbox: \(adapter.mailbox.email)")
        
        state = .Finished
        callback( messages: messages, error: error)
        
    }
}


