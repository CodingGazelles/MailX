//
//  MxTickets.swift
//  Hexmail
//
//  Created by Tancrède on 3/14/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



typealias MxFetchLabelListCallback = (labels: [MxLabelRemote]?, error: MxAdapterError?) -> Void

class MxFetchLabelListCommand : MxNetworkCommand {
    

    var callback: MxFetchLabelListCallback
    
    init( adapter: MxMailboxAdapter, callback: MxFetchLabelListCallback) {
        
        self.callback = callback
        super.init( adapter: adapter)
        
    }
    
    override func main() {
        
        MxLog.debug("\(#function) fetch labels ticket sending request to mailbox: \(adapter.mailbox.email)")
        adapter.sendFetchLabelListRequest( callback: adapterDidFetchLabelList)
        
    }
    
    func adapterDidFetchLabelList( labels labels: [MxLabelRemote]?, error: MxAdapterError?) {
        
        MxLog.debug("\(#function) fetch labels ticket received response of mailbox: \(adapter.mailbox.email)")
        state = .Finished
        callback( labels: labels, error: error)
        
    }
}


