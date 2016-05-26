//
//  MxFetchMessagesInLabelTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchMessagesInLabelCompletionHandler = (messages: [MxMessageModel]?, error: NSError?) -> Void


class MxFetchMessagesInLabelTicket : MxProxyTicket {
    
    var completionHandler: MxFetchMessagesInLabelCompletionHandler
    var labelId: MxLabelModel.Id
    
    init( labelId: MxLabelModel.Id, proxy: MxMailboxProxy, completionHandler: MxFetchMessagesInLabelCompletionHandler) {
        MxLog.verbose("... labelId: \(labelId)")
        
        self.completionHandler = completionHandler
        self.labelId = labelId
        super.init( proxy: proxy)
        
        MxLog.verbose("... Done")
    }
    
    override func main() {
        MxLog.verbose("...")
        
        MxLog.debug("Fetch messages ticket sending request to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        proxy.sendFetchMessagesInLabelRequest( labelId: labelId, completionHandler: proxyDidFetchMessagesInLabel)
        
        MxLog.verbose("... Done")
    }
    
    func proxyDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: NSError?) {
        MxLog.verbose("...")
        
        MxLog.debug("Fetch messages ticket received response of proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        state = .Finished
        completionHandler( messages: messages, error: error)
        
        MxLog.verbose("... Done")
    }
}


