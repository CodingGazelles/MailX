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
    private var mailbox: MxMailboxModel
    private var connectPromise: Promise<Any, MxProxyError>!
    
    
    init( mailbox: MxMailboxModel){
        
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
        if( error == nil) {
            
            MxLog.debug("Proxy is connected to mailbox: \(mailbox.email)")
            
            connectPromise.success(true)
            
        } else {
            
            MxLog.error("Unable to connect adapter to mailbox \(mailbox.email)", error: error)
            
            let proxyError = MxProxyError.AdapterDidNotConnect(rootError: error!)
            connectPromise.failure( proxyError)
            
        }
    }
    
    
    // MARK: - Fetch labels
    
    func fetchLabels() {
        
        MxLog.verbose("\(#function) creating fetch labels operation to mailbox: \(adapter.mailbox)")
        
        let ticket = MxFetchLabelsCommand( adapter: adapter, callback: adapterDidFetchLabels)
        operationsQueue.addOperation(ticket)
    }
    
    func adapterDidFetchLabels(labels labels: [MxLabelModel]?, error: MxAdapterError?) {
        
        MxLog.debug("\(#function): receiving response from mailbox: \(mailbox.email) labels=\(labels), error=\(error)")
        
//        syncManager.remoteDataHasArrived(
//            mailbox: mailbox
//            , payload: labels!
//            , error: error != nil ? MxProxyError.adapterReturnedError(rootError: error!) : nil)
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Fetch messages
    
    func fetchMessagesInLabel( labelId labelId: MxObjectId) {
        MxLog.debug("Processing \(#function). Args: labelId: \(labelId)")
        
        MxLog.verbose("Creating fetch messages ticket to mailbox: \(adapter.mailbox)")
        
        let ticket = MxFetchMessagesCommand( labelId: labelId, adapter: adapter, callback: adapterDidFetchMessagesInLabel)
        operationsQueue.addOperation(ticket)
    }
    
    func adapterDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: MxAdapterError?) {
        MxLog.verbose("... Processing. Args: messages=\(messages), error=\(error)")
        
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Push actions
    
    /*
    Push local alterations to remote mailbox
    */
    
    func pushTickets( mailboxId mailboxId: MxObjectId){
    
    }
}