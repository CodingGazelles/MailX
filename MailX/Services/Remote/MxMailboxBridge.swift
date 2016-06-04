//
//  MxProxy.swift
//  Hexmail
//
//  Created by Tancrède on 3/7/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation


protocol MxMailboxBridge {
    
    func connect( completionHandler completionHandler: MxConnectCompletionHandler)
    func sendFetchLabelsRequest( completionHandler completionHandler: MxFetchLabelsCompletionHandler)
    func sendFetchMessagesInLabelRequest(labelId labelId: MxLabelModelId, completionHandler: MxFetchMessagesInLabelCompletionHandler)
    
//    func didFetchMessagesHandler( selector: Selector, error: NSError)
    
//    func sendFetchThreadsRequest(label: MxLabelModel)
//    func didFetchThreadsHandler( selector: Selector, error: NSError)
    
    var mailbox: MxMailboxModel { get }
    
}

class MxBridgeFactory {
    static func gmailBridge( mailbox mailbox: MxMailboxModel) -> MxMailboxBridge {
        return MxGMailBridge( mailbox: mailbox)
    }
}


