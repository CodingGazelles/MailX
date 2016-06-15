//
//  MxRemoteStoreDelegate.swift
//  Hexmail
//
//  Created by Tancrède on 3/6/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation

import BrightFutures



class MxMailboxProxy {
    
    private var adapter: MxMailboxAdapter
    private var operationsQueue: NSOperationQueue
    private var mailbox: MxMailbox
    
    private var connectPromise: Promise<Any, MxProxyError>!
    private var fetchLabelsPromise: Promise<[MxLabel], MxProxyError>!
    
    
    init( mailbox: MxMailbox){
        
        self.mailbox = mailbox
        
        let adapter = MxAdapterFactory.gmailAdapter( mailbox: mailbox)
        self.adapter = adapter
        
        operationsQueue = NSOperationQueue()
        operationsQueue.name = mailbox.email
        operationsQueue.maxConcurrentOperationCount = 1
    }
    
    
    // MARK: - Connect adapter
    
    func connect() -> Future<Any, MxProxyError> {
        
        MxLog.debug("Adding connection command to operation queue for mailbox: \(mailbox.email)")
        
        connectPromise = Promise<Any, MxProxyError>()
        
        ImmediateExecutionContext {
            
            let ticket = MxConnectionCommand( adapter: self.adapter, callback: self.adapterDidConnect)
            self.operationsQueue.addOperation( ticket)

        }
        
        return connectPromise.future
    }
    
    func adapterDidConnect(error error: MxAdapterError?){
        
        MxLog.debug("Received response from connect command \(mailbox.email), error=\(error)")
        
        if( error == nil) {
            
            MxLog.debug("Proxy did connect to mailbox: \(mailbox.email)")
            
            connectPromise.success(true)
            
        } else {
            
            MxLog.error("Unable to connect adapter to mailbox \(mailbox.email)", error: error)
            
            let proxyError = MxProxyError.AdapterDidNotConnect(rootError: error!)
            connectPromise.failure( proxyError)
            
        }
    }
    
    
    // MARK: - Fetch labels
    
    func fetchLabels() -> Future<[MxLabel], MxProxyError>{
        
        MxLog.debug("Adding fetch labels command to operation queue for mailbox: \(mailbox.email)")
        
        fetchLabelsPromise = Promise<[MxLabel], MxProxyError>()
        
        ImmediateExecutionContext {
            
            let ticket = MxFetchLabelsCommand( adapter: self.adapter, callback: self.adapterDidFetchLabels)
            self.operationsQueue.addOperation(ticket)
            
        }
        
        return fetchLabelsPromise.future
    }
    
    func adapterDidFetchLabels(labels labels: [MxLabel]?, error: MxAdapterError?) {
        
        MxLog.debug("Received response from fetchLabels command \(mailbox.email) labels=\(labels), error=\(error)")
        
        if error == nil {
            
            MxLog.debug("Proxy did fetch labels of mailbox: \(mailbox.email)")
            
            fetchLabelsPromise.success(labels!)
            
        } else {
            
            MxLog.error("Unable to fetchLabels of mailbox \(mailbox.email)", error: error)
            
            let proxyError = MxProxyError.AdapterDidNotFetchLabels(rootError: error!)
            fetchLabelsPromise.failure( proxyError)
            
        }
        
    }
    
    
    // MARK: - Fetch messages
    
    func fetchMessagesInLabel( labelId labelId: MxRemoteId) {
        MxLog.debug("Processing \(#function). Args: labelId: \(labelId)")
        
        MxLog.debug("Creating fetch messages ticket to mailbox: \(adapter.mailbox)")
        
        let ticket = MxFetchMessagesCommand( labelId: labelId, adapter: adapter, callback: adapterDidFetchMessagesInLabel)
        operationsQueue.addOperation(ticket)
    }
    
    func adapterDidFetchMessagesInLabel( messages messages: [MxMessage]?, error: MxAdapterError?) {
        MxLog.verbose("... Processing. Args: messages=\(messages), error=\(error)")
        
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Push actions
    
    /*
    Push local alterations to remote mailbox
    */
    
//    func pushTickets( mailboxId mailboxId: MxObjectId){
//    
//    }
}