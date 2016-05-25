//
//  MxSyncManager.swift
//  Hexmail
//
//  Created by Tancrède on 4/2/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import Result



enum MxSyncError: MxException {
    case PersistenceManagerIsNil(rootError: MxException? )
    case SyncManagerIsNil(rootError: MxException?)
    case UnableToRealizeDBOperation(rootError: MxException?)
}

class MxSyncManager {
    
    // MARK: - Private properties
    
    private let localStore = { () -> MxPersistenceManager? in
        switch MxPersistenceManager.defaultManager() {
        case let .Success(manager):
            return manager
            
        case let .Failure(error):
            MxLog.error("Unable to get an instance of the persistence manager"
                , error: MxSyncError.PersistenceManagerIsNil(rootError: error))
            return nil
        }
    }()
    
    private var remoteStores = Dictionary<MxMailboxModelId, MxMailboxHelper>()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> Result<MxSyncManager, MxSyncError> in
        let manager = MxSyncManager()
        
        guard (manager.localStore != nil) else {
            return .Failure( MxSyncError.SyncManagerIsNil(rootError: nil))
        }
        
        switch manager.localStore!.fetchMailboxes() {
        case let .Success(mailboxes):
            
            for mailbox in mailboxes {
                switch mailbox {
                    case let .Success(mailboxModel):
                    
                        let remoteStore = MxMailboxHelper( mailbox: mailboxModel)
                        manager.remoteStores[mailboxModel.id] = remoteStore
                    
                    case let .Failure(error):
                    
                        MxLog.error("Unable to fetch one mailbox", error: error)
                }
                
            }
            return .Success(manager)
            
        case let .Failure(error):
            MxLog.error("Unable to fetch mailboxes", error: error)
            return .Failure(MxSyncError.UnableToRealizeDBOperation(rootError: error))
        }
        
    }()
        
    
    static func defaultManager() -> Result<MxSyncManager, MxSyncError> {
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
    func emptyAllDataOfMailbox( mailboxId mailboxId: MxMailboxModelId) -> Result<Bool, MxSyncError>{
        MxLog.verbose("... Processing. Args: mailboxId: \(mailboxId)")
        
        guard localStore != nil else {
            return .Failure(
                MxSyncError.PersistenceManagerIsNil(rootError: nil))
        }
        
        switch localStore!.fetchLabels( mailboxId: mailboxId) {
        case let .Success( labels):
            MxLog.debug("Deleting messages in labels. Args: mailboxId: \(mailboxId)")
            
            for label in labels {
                
                switch label {
                case let .Success(labelModel):
                    localStore!.deleteMessages( mailboxId: mailboxId, labelId: labelModel.id)
                    
                case let .Failure(error):
                    MxLog.error("Unable to fetch one label", error: error)
                }
                
            }
            
        case let .Failure( error):
            MxLog.error("Unable to fetch labels of mailbox mailboxId: \(mailboxId)", error: error)
            return .Failure(MxSyncError.UnableToRealizeDBOperation(rootError: error))
        }
        
        MxLog.debug("Deleting mailbox's labels. Args: mailboxId: \(mailboxId)")
        
        localStore!.deleteLabels( mailboxId: mailboxId)
        
        // todo: delete threads
        
        MxLog.verbose("... Done");
        return .Success(true)
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