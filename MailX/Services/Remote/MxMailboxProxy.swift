//
//  MxRemoteStoreDelegate.swift
//  Hexmail
//
//  Created by Tancrède on 3/6/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation



class MxMailboxProxy {
    
    lazy private var syncManager = { () -> MxSyncManager in
        return MxSyncManager.defaultManager()
    }()
    
    private var bridge: MxMailboxBridge
    private var isConnected = false
    private var operationsQueue: NSOperationQueue
    private var mailbox: MxMailboxModel
    
    
    init( mailbox: MxMailboxModel){
        
        self.mailbox = mailbox
        
        let bridge = MxBridgeFactory.gmailBridge( mailbox: mailbox)
        self.bridge = bridge
        
        operationsQueue = NSOperationQueue()
        operationsQueue.name = mailbox.id.remoteId.value
        operationsQueue.maxConcurrentOperationCount = 1
    }
    
    
    // MARK: - Connect bridge
    
    func connect() {
        
        MxLog.debug("\(#function) creating connection operation to mailbox: \(mailbox.email)")
        
        let ticket = MxConnectionOperation( bridge: bridge, completionHandler: bridgeDidConnect)
        operationsQueue.addOperation( ticket)
    }
    
    func bridgeDidConnect(error error: MxBridgeError?){
        if( error == nil) {
            
            MxLog.debug("Proxy is connected to mailbox: \(mailbox.email)")
            
            isConnected = true
            mailbox.connected = true
            
        } else {
            
            MxLog.error("Unable to connect to mailbox \(mailbox.email)", error: error)
            
            fatalError( MxProxyError.BridgeReturnedError(rootError: error!).debugDescription)
        }
    }
    
    
    // MARK: - Fetch labels
    
    func fetchLabels() {
        
        MxLog.verbose("\(#function) creating fetch labels operation to mailbox: \(bridge.mailbox)")
        
        let ticket = MxFetchLabelsOperation( bridge: bridge, completionHandler: bridgeDidFetchLabels)
        operationsQueue.addOperation(ticket)
    }
    
    func bridgeDidFetchLabels(labels labels: [MxLabelModel]?, error: MxBridgeError?) {
        
        MxLog.debug("\(#function): receiving response from mailbox: \(mailbox.email) labels=\(labels), error=\(error)")
        
        syncManager.remoteDataHasArrived(
            mailbox: mailbox
            , payload: labels!
            , error: error != nil ? MxProxyError.BridgeReturnedError(rootError: error!) : nil)
        
        
        MxLog.verbose("...")
    }
    
    
    // MARK: - Fetch messages
    
    func fetchMessagesInLabel( labelId labelId: MxObjectId) {
        MxLog.debug("Processing \(#function). Args: labelId: \(labelId)")
        
        MxLog.verbose("Creating fetch messages ticket to mailbox: \(bridge.mailbox)")
        
        let ticket = MxFetchMessagesInLabelOperation( labelId: labelId, bridge: bridge, completionHandler: bridgeDidFetchMessagesInLabel)
        operationsQueue.addOperation(ticket)
    }
    
    func bridgeDidFetchMessagesInLabel( messages messages: [MxMessageModel]?, error: MxBridgeError?) {
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