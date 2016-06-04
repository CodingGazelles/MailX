//
//  MxTickets.swift
//  Hexmail
//
//  Created by Tancrède on 3/14/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchLabelsCompletionHandler = (labels: [MxLabelModel]?, error: MxBridgeError?) -> Void

class MxFetchLabelsOperation : MxSyncOperation {
    

    var completionHandler: MxFetchLabelsCompletionHandler
    
    init( bridge: MxMailboxBridge, completionHandler: MxFetchLabelsCompletionHandler) {
        
        self.completionHandler = completionHandler
        super.init( bridge: bridge)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) fetch labels ticket sending request to mailbox: \(bridge.mailbox.email)")
        bridge.sendFetchLabelsRequest( completionHandler: bridgeDidFetchLabels)
        
    }
    
    func bridgeDidFetchLabels( labels labels: [MxLabelModel]?, error: MxBridgeError?) {
        
        MxLog.debug("\(#function) fetch labels ticket received response of mailbox: \(bridge.mailbox)")
        state = .Finished
        completionHandler( labels: labels, error: error)
        
    }
}


