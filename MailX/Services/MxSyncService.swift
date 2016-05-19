//
//  MxSyncManager.swift
//  Hexmail
//
//  Created by Tancrède on 4/2/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation






class MxSyncServices {
    
    
    // MARK: -
    
    private let localStore = MxStoreManager.sharedDb()
    private var remoteStores = Dictionary<MxModelId, MxRemoteStoreHelper>()
    
    
//    // MARK: - Shared instance
//    
//    private static let sharedInstance = MxSyncManager()
//    static func sharedSyncManager() -> MxSyncManager {
//        return sharedInstance
//    }
    
    
    
    init() {
        MxLog.verbose("... Processing.")
        
        switch localStore.fetchMailboxes() {
        case let .Success(mailboxes):
            for mailbox in mailboxes {
                let remoteStore = MxRemoteStoreHelper( mailbox: mailbox)
                remoteStores[mailbox.id] = remoteStore
            }
            
        case let .Failure(error):
            sendErrorNotification( message: "Unable to fetch mailboxes.",error: error)
        }
        
        MxLog.verbose("... Done.")
    }
    
    
    
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
    func updatePartial( mailboxId mailboxId: MxModelId){
        MxLog.debug("Doing partial update of mailbox: \(mailboxId)")
        
        fatalError("Func not implemented")
    }
    
    func updateFull(mailboxId mailboxId: MxModelId){
        MxLog.debug("Doing full update of mailbox: \(mailboxId)")
        
        emptyAllDataOfMailbox(mailboxId: mailboxId)
        fetchAllDataOfMailbox(mailboxId: mailboxId)
    }
    
    // full update
    func emptyAllDataOfMailbox( mailboxId mailboxId: MxModelId){
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
    
    func fetchAllDataOfMailbox( mailboxId mailboxId: MxModelId){
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