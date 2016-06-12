//
//  MxTickets.swift
//  Hexmail
//
//  Created by Tancrède on 3/14/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchLabelsCallback = (labels: [MxLabelModel]?, error: MxBridgeError?) -> Void

class MxFetchLabelsCommand : MxNetworkCommand {
    

    var callback: MxFetchLabelsCallback
    
    init( adapter: MxMailboxAdapter, callback: MxFetchLabelsCallback) {
        
        self.callback = callback
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) fetch labels ticket sending request to mailbox: \(adapter.mailbox.email)")
        adapter.sendFetchLabelsRequest( callback: bridgeDidFetchLabels)
        
    }
    
    func bridgeDidFetchLabels( labels labels: [MxLabelModel]?, error: MxBridgeError?) {
        
        MxLog.debug("\(#function) fetch labels ticket received response of mailbox: \(adapter.mailbox.email)")
        state = .Finished
        callback( labels: labels, error: error)
        
    }
}


