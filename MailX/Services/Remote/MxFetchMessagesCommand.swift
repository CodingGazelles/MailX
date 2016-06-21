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
    var labelIds: [MxLabelCode]
    
    init( labelIds: [MxLabelCode], adapter: MxMailboxAdapter, callback: MxFetchMessageListCallback) {
        
        self.callback = callback
        self.labelIds = labelIds
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("Fetch messages command sending request to mailbox: \(adapter.mailbox.email)")
        
        adapter.sendFetchMessageListInLabelsRequest( labelIds: labelIds, callback: adapterDidFetchMessageList)
        
    }
    
    func adapterDidFetchMessageList( messages messages: [MxMessageRemote]?, error: MxAdapterError?) {
        
        MxLog.debug("Fetch messages ticket received response of mailbox: \(adapter.mailbox.email)")
        
        state = .Finished
        callback( messages: messages, error: error)
        
    }
}


