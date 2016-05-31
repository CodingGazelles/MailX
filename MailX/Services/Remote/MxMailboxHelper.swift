//
//  MxRemoteStoreDelegate.swift
//  Hexmail
//
//  Created by Tancrède on 3/6/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



class MxMailboxHelper {
    
    
    private var proxy: MxMailboxProxy
    private var isConnected = false
    private var operationsQueue: NSOperationQueue
    
    
    init( mailbox: MxMailboxModel){
        MxLog.debug("Processing \(#function). Args: mailbox=\(mailbox)")
        
        let proxy = MxProxyFactory.gmailProxy( providerCode: mailbox.providerCode, mailboxId: mailbox.remoteId)
        self.proxy = proxy
        
        operationsQueue = NSOperationQueue()
        operationsQueue.name = mailbox.remoteId.value
        operationsQueue.maxConcurrentOperationCount = 1
    }
    
    
    // MARK: - Connect proxy
    
    func connect() {
        MxLog.debug("Processing \(#function).");
        
        MxLog.verbose("Creating connection ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxConnectionTicket( proxy: proxy, completionHandler: proxyDidConnect)
        operationsQueue.addOperation( ticket)
    }
    
    func proxyDidConnect(error error: NSError?){
        if( error == nil) {
            isConnected = true
        } else {
            fatalError( error!.localizedDescription)
        }
    }
    
    
    // MARK: - Fetch labels
    
    func fetchLabels() {
        MxLog.debug("Processing \(#function).")
        
        MxLog.verbose("Creating fetch labels ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxFetchLabelsTicket( proxy: proxy, completionHandler: proxyDidFetchLabels)
        operationsQueue.addOperation(ticket)
    }
    
    func proxyDidFetchLabels(labels labels: [MxLabelModel]?, error: NSError?) {
        MxLog.verbose("... Processing. Args: labels=\(labels), error=\(error)")
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Fetch messages
    
    func fetchMessagesInLabel( labelId labelId: MxLabelModel.Id) {
        MxLog.debug("Processing \(#function). Args: labelId: \(labelId)")
        
        MxLog.verbose("Creating fetch messages ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxFetchMessagesInLabelTicket( labelId: labelId, proxy: proxy, completionHandler: proxyDidFetchMessagesInLabel)
        operationsQueue.addOperation(ticket)
    }
    
    func proxyDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: NSError?) {
        MxLog.verbose("... Processing. Args: messages=\(messages), error=\(error)")
        
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Push actions
    
    /*
    Push local alterations to remote mailbox
    */
    
    func pushTickets( mailboxId mailboxId: MxMailboxModel.Id){
    
    }
}