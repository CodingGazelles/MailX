//
//  MxSyncManager.swift
//  Hexmail
//
//  Created by Tancrède on 4/2/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import Result



class MxSyncManager {
    
    
    // MARK: - Private properties
    
    private let localStore = { () -> MxPersistenceManager? in
        switch MxPersistenceManager.defaultManager() {
        case let .Success(manager):
            return manager
            
        case let .Failure(error):
            MxLog.error("Unable to get persistence manager", error: error)
            return nil
        }
    }()
    
    private var remoteStores = Dictionary<MxMailboxModelId, MxMailboxHelper>()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> Result<MxSyncManager, MxError> in
        let manager = MxSyncManager()
        
        guard (manager.localStore != nil) else {
            return .Failure(MxError.InternalStateIncoherent(
                operationName: "MxSyncManager.sharedInstance"
                , message: "localStore is nill") )
        }
        
        switch manager.localStore!.fetchMailboxes() {
        case let .Success(mailboxes):
            
            for mailbox in mailboxes {
                let remoteStore = MxMailboxHelper( mailbox: mailbox)
                manager.remoteStores[mailbox.id] = remoteStore
            }
            return .Success(manager)
            
        case let .Failure(error):
            MxLog.error("Unable to initialize sync manager", error: error)
            return .Failure(error)
        }
        
    }()
        
    
    static func defaultManager() -> Result<MxSyncManager, MxError> {
        return sharedInstance
    }
    
    private init(){}
    
    
    //MARK: - Synchronize local mailboxes with remote store
    
    func startSynchronization(){
        MxLog.verbose("... Processing.")
        
        MxLog.debug("Init connections to providers")
        for (_, remoteStore) in remoteStores {
            remoteStore.connect()
        }
        
        
        MxLog.debug("Update local information")
        self.updateMailboxes()
        
        
        MxLog.debug("Start synchronization (initiating push data from providers)")
        //todo
        
        MxLog.verbose("... Done");
    }
    
    func syncMailboxes() {
        
    }
    
    
    //MARK: - Update local store with remote data
    
    func updateMailboxes(){
        MxLog.verbose("... Processing.")
        
        for (mailboxId, _) in remoteStores {
            // pullHistory
            // todo
            //
//            MxLog.debug("Partial update of mailbox: \(mailboxId)")
            //        updatePartial(mailboxId: mailboxId)
            
            
            MxLog.debug("Full update of mailbox: \(mailboxId)")
            updateFull(mailboxId: mailboxId)
        }
        
        MxLog.verbose("... Done");
    }
    
    // incremental update
    func updateIncremental( mailboxId mailboxId: MxMailboxModelId){
        MxLog.debug("Doing incremental update of mailbox: \(mailboxId)")
        
        fatalError("Func not implemented")
    }
    
    func updateFull(mailboxId mailboxId: MxMailboxModelId){
        MxLog.debug("Doing full update of mailbox: \(mailboxId)")
        
        emptyAllDataOfMailbox(mailboxId: mailboxId)
        fetchAllDataOfMailbox(mailboxId: mailboxId)
    }
    
    // full update
    func emptyAllDataOfMailbox( mailboxId mailboxId: MxMailboxModelId){
        MxLog.verbose("... Processing. Args: mailboxId: \(mailboxId)")
        
        MxLog.debug("Deleting messages in labels. Args: mailboxId: \(mailboxId)")
        
        switch localStore.fetchLabels( mailboxId: mailboxId) {
        case let .Success( labels):
            for label in labels {
                localStore.deleteMessages( mailboxId: mailboxId, labelId: label.id)
            }
            
        case let .Failure( error):
            sendErrorNotification( message: "Unable to fetch labels. Args: mailboxId: \(mailboxId)",error: error)
        }
        
        
        MxLog.debug("Deleting user labels. Args: mailboxId: \(mailboxId)")
        
        localStore.deleteLabels( mailboxId: mailboxId)
        
        // todo: delete threads
        
        MxLog.verbose("... Done");
    }
    
    func fetchAllDataOfMailbox( mailboxId mailboxId: MxMailboxModelId){
        MxLog.verbose("... mailboxId: \(mailboxId)")
        
        // fetch messages in INBOX
        MxLog.debug("Deleting messages in INBOX for mailbox: \(mailboxId)")
        remoteStores[mailboxId]!.fetchMessagesInLabel(labelId: MxLabelModel.Id(value: "INBOX"))
        
        //        // fetch labels
        //        remoteStores[mailboxId]!.fetchLabels()
        //
        //        // sync messages of system labels
        //        let labels = localStore.fetchLabels(mailboxId: mailboxId)
        //
        //        for label in labels {
        //            if( label.type == MxLabelModel.OwnerType.SYSTEM){
        //                remoteStores[mailboxId]!.fetchMessagesInLabel(labelId: label.id)
        //            }
        //        }
        
        MxLog.verbose("... Done");
    }
    
    
}