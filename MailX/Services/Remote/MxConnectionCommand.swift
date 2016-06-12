//
//  MxConnectionTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/15/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxConnectCallback = (error: MxAdapterError?) -> Void

class MxConnectionCommand : MxNetworkCommand {
    
    
    var callback: MxConnectCallback
    
    init( adapter: MxMailboxAdapter, callback: MxConnectCallback) {
        
        self.callback = callback
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) connection ticket sending request to mailbox: \(adapter.mailbox.email)")
        adapter.connect( callback: bridgeDidConnect)
        
    }
    
    func bridgeDidConnect( error error: MxAdapterError?) {
        
        MxLog.debug("\(#function) connection operation received response of mailbox: \(adapter.mailbox.email)")
        state = .Finished
        callback( error: error)
        
    }
    

}