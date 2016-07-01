//
//  MxProxy.swift
//  Hexmail
//
//  Created by Tancrède on 3/7/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation


protocol MxMailboxAdapter {
    
    func connect( callback callback: MxConnectCallback)
    func sendFetchLabelListRequest( callback callback: MxFetchLabelListCallback)
    func sendFetchMessageListInLabelsRequest(labelCodes labelCodes: [MxLabelCode], callback: MxFetchMessageListCallback)
    func sendFetchMessageRequest(messagesId messageId: MxRemoteId, callback: MxFetchMessageCallback)
    
//    func didFetchMessagesHandler( selector: Selector, error: NSError)
    
//    func sendFetchThreadsRequest(label: MxLabel)
//    func didFetchThreadsHandler( selector: Selector, error: NSError)
    
    var mailbox: MxMailbox { get }
    
}

class MxAdapterFactory {
    static func gmailAdapter( mailbox mailbox: MxMailbox) -> MxMailboxAdapter {
        return MxGMailAdapter( mailbox: mailbox)
    }
}


