//
//  MxFetchMessageCommand.swift
//  MailX
//
//  Created by Tancrède on 6/22/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



typealias MxFetchMessageCallback = (message: MxMessageRemote?, error: MxAdapterError?) -> Void


class MxFetchMessageCommand : MxNetworkCommand {
    
    var callback: MxFetchMessageCallback
    var messageId: MxRemoteId
    
    init( messageId: MxRemoteId, adapter: MxMailboxAdapter, callback: MxFetchMessageCallback) {
        
        self.callback = callback
        self.messageId = messageId
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("Fetch message command sending request to mailbox: \(adapter.mailbox.email) \(messageId)")
        
        adapter.sendFetchMessageRequest( messagesId: messageId, callback: adapterDidFetchMessage)
        
    }
    
    func adapterDidFetchMessage( message message: MxMessageRemote?, error: MxAdapterError?) {
        
        MxLog.debug("Fetch message command received response of mailbox: \(adapter.mailbox.email) \(messageId)")
        
        state = .Finished
        callback( message: message, error: error)
        
    }
}