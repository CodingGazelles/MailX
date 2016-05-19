//
//  MxTickets.swift
//  Hexmail
//
//  Created by Tancrède on 3/14/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation






typealias MxFetchLabelsCompletionHandler = (labels: MxLabelModelArray?, error: NSError?) -> Void

class MxFetchLabelsTicket : MxProxyTicket {
    

    var completionHandler: MxFetchLabelsCompletionHandler
    
    init( proxy: MxMailboxProxy, completionHandler: MxFetchLabelsCompletionHandler) {
        MxLog.verbose("...")
        
        self.completionHandler = completionHandler
        super.init( proxy: proxy)
        
        MxLog.verbose("... Done")
    }
    
    override func main() {
        MxLog.verbose("...")
        
        MxLog.debug("Fetch labels ticket sending request to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        proxy.sendFetchLabelsRequest( completionHandler: proxyDidFetchLabels)
        
        MxLog.verbose("... Done")
    }
    
    func proxyDidFetchLabels( labels labels: MxLabelModelArray?, error: NSError?) {
        MxLog.verbose("...")
        
        MxLog.debug("Fetch labels ticket received response of proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        state = .Finished
        completionHandler( labels: labels, error: error)
        
        MxLog.verbose("... Done")
    }
}


