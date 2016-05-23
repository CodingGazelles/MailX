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
        MxLog.verbose("... Processing. Args: mailbox=\(mailbox)")
        
        let proxy = MxProxyFactory.gmailProxy( providerId: mailbox.providerId, mailboxId: mailbox.id)
        self.proxy = proxy
        
        operationsQueue = NSOperationQueue()
        operationsQueue.name = mailbox.id.value
        operationsQueue.maxConcurrentOperationCount = 1
        
        MxLog.verbose("... Done")
    }
    
    
    // MARK: - Connect proxy
    
    func connect() {
        MxLog.verbose("... Processing.");
        
        MxLog.debug("Creating connection ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxConnectionTicket( proxy: proxy, completionHandler: proxyDidConnect)
        operationsQueue.addOperation( ticket)
        
        MxLog.verbose("... Done")
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
        MxLog.verbose("... Processing.")
        
        MxLog.debug("Creating fetch labels ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxFetchLabelsTicket( proxy: proxy, completionHandler: proxyDidFetchLabels)
        operationsQueue.addOperation(ticket)
        
        MxLog.verbose("... Done")
    }
    
    func proxyDidFetchLabels(labels labels: MxLabelModelArray?, error: NSError?) {
        MxLog.verbose("... Processing. Args: labels=\(labels), error=\(error)")
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Fetch messages
    
    func fetchMessagesInLabel( labelId labelId: MxLabelModel.Id) {
        MxLog.verbose("... Processing.")
        
        MxLog.debug("Creating fetch messages ticket to proxy: \(proxy.getProviderId().value+"/"+proxy.getMailboxId().value)")
        let ticket = MxFetchMessagesInLabelTicket( labelId: labelId, proxy: proxy, completionHandler: proxyDidFetchMessagesInLabel)
        operationsQueue.addOperation(ticket)
        
        MxLog.verbose("... Done")
    }
    
    func proxyDidFetchMessagesInLabel( messages messages: MxMessageModelArray?, error: NSError?) {
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