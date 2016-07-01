//
//  MxFetchMessagesInLabelTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchMessageListCallback = (messages: [MxMessageRemote]?, error: MxAdapterError?) -> Void


class MxFetchMessageListCommand : MxNetworkCommand {
    
    var callback: MxFetchMessageListCallback
    var labelCodes: [MxLabelCode]
    
    init( labelCodes: [MxLabelCode], adapter: MxMailboxAdapter, callback: MxFetchMessageListCallback) {
        
        self.callback = callback
        self.labelCodes = labelCodes
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("Fetch messages command sending request to mailbox: \(adapter.mailbox.email)")
        
        adapter.sendFetchMessageListInLabelsRequest( labelCodes: labelCodes, callback: adapterDidFetchMessageList)
        
    }
    
    func adapterDidFetchMessageList( messages messages: [MxMessageRemote]?, error: MxAdapterError?) {
        
        MxLog.debug("Fetch messages ticket received response of mailbox: \(adapter.mailbox.email)")
        
        state = .Finished
        callback( messages: messages, error: error)
        
    }
}


