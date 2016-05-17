//
//  MxConnectionTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation





typealias MxConnectCompletionHandler = (error: NSError?) -> Void


class MxConnectionTicket : MxProxyTicket {
    
    
    var completionHandler: (error: NSError?) -> Void
    
    init( proxy: MxMailboxProxy, completionHandler: MxConnectCompletionHandler) {
        MxLog.verbose("...")
        
        self.completionHandler = completionHandler
        super.init( proxy: proxy)
        
        MxLog.verbose("... Done")
    }
    
    override func main() {
        MxLog.verbose("...")
        
        MxLog.debug("Connection ticket sending request to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        proxy.connect( completionHandler: proxyDidConnect)
        
        MxLog.verbose("... Done")
    }
    
    func proxyDidConnect( error error: NSError?) {
        MxLog.verbose("...")
        
        
        MxLog.debug("Connection ticket received response of proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        state = .Finished
        completionHandler( error: error)
        
        MxLog.verbose("... Done")
    }
    

}