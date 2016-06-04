//
//  MxConnectionTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxConnectCompletionHandler = (error: MxBridgeError?) -> Void

class MxConnectionOperation : MxSyncOperation {
    
    
    var completionHandler: MxConnectCompletionHandler
    
    init( bridge: MxMailboxBridge, completionHandler: MxConnectCompletionHandler) {
        
        self.completionHandler = completionHandler
        super.init( bridge: bridge)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) connection ticket sending request to mailbox: \(bridge.mailbox.email)")
        bridge.connect( completionHandler: bridgeDidConnect)
        
    }
    
    func bridgeDidConnect( error error: MxBridgeError?) {
        
        MxLog.debug("\(#function) connection operation received response of mailbox: \(bridge.mailbox.email)")
        state = .Finished
        completionHandler( error: error)
        
    }
    

}