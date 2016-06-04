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
    case UnableToRealizeModelOperation(rootError: MxException?)
}

class MxSyncManager {
    
    
    // MARK: - Private properties
    
    private let stateManager = MxStateManager.defaultManager()
    
    private let dbManager = { () -> MxPersistenceManager in
        return MxPersistenceManager.defaultManager()
    }()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> MxSyncManager in
        
        let syncManager = MxSyncManager()
        
        for mailbox in MxSyncManager.allMailboxes() {
            
            let proxy = MxMailboxProxy( mailbox: mailbox)
            mailbox.proxy = proxy
            
        }
        
        return syncManager
    }()
    
    static func defaultManager() -> MxSyncManager {
        return sharedInstance
    }
    
    private static func allMailboxes() -> [MxMailboxModel] {
    
        var mailboxes = [MxMailboxModel]()
        
        switch MxMailboxModel.fetch() {
        case let .Success(results):
            
            for result in results {
                switch result {
                case let .Success(mailbox):
                    
                    mailboxes.append(mailbox)
                    
                case let .Failure(error):
                    
                    MxLog.error("Unable to fetch one mailbox", error: error)
                    
                    let error = MxSyncError.UnableToRealizeModelOperation(rootError: error)
                    MxStateManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
                }
                
            }
            
        case let .Failure(error):
            
            MxLog.error("Unable to fetch mailboxes", error: error)
            
            let error = MxSyncError.UnableToRealizeModelOperation(rootError: error)
            MxStateManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
            
        }
        
        return mailboxes
        
    }
    
    private init(){}
    
    
    //MARK: - Synchronize local mailboxes with remote store
    
    func startSynchronization(){
        
        MxLog.debug("\(#function): initiating sync of local db with remote mailbox")
        
        for mailbox in MxSyncManager.allMailboxes() {
            
            MxLog.debug("Connecting to remote mailbox \(mailbox.email)")
            mailbox.proxy.connect()
            
        }
        
        MxLog.debug("Updating local information")
        
        updateMailboxes()
        
        MxLog.debug("Starting synchronization (initiating pulling data from providers)")
        
        syncMailboxes()
        
    }
    
    func syncMailboxes() {
        //todo
    }
    
    
    //MARK: - Update local store with remote data
    
    func updateMailboxes(){
        
        MxLog.debug("\(#function): updating all mailboxes ")
        
        for mailbox in MxSyncManager.allMailboxes() {
            // pullHistory
            // todo
            //
//            MxLog.debug("Partial update of mailbox: \(mailboxId)")
            //        updatePartial(mailboxId: mailboxId)
            
            runFullUpdate(mailbox: mailbox)
        }
    }
    
    // incremental update
    func runIncrementalUpdate( mailboxId mailboxId: MxMailboxModelId){
        
        MxLog.debug("Doing incremental update of mailbox: \(mailboxId)")
        
        fatalError("Func not implemented")
    }
    
    func runFullUpdate(mailbox mailbox: MxMailboxModel){
        
        MxLog.debug("\(#function): processing full update of mailbox: \(mailbox.email)")
        
        emptyLocalData(mailbox: mailbox)
        fetchRemoteData(mailbox: mailbox)
        
    }
    
    // full update
    func emptyLocalData( mailbox mailbox: MxMailboxModel) {
        
        MxLog.debug("\(#function): processing full delete of local data of mailbox: \(mailbox.email)")
        
        let mailboxDbo = mailbox.dbo
        let labels = mailboxDbo!.labels
        
        MxLog.debug("Deleting messages of mailbox: \(mailbox.email)")
        
        for label in labels {
            
            for message in label.messages {
                
                switch message.delete() {
                case .Success:
                    
                    MxLog.debug("Message deleted: \(label)")
                    
                case let .Failure(error):
                    
                    let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
                    MxStateManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
                    
                }
            }
        }
        
        MxLog.debug("Deleting labels of mailbox: \(mailbox.email)")
        
        for label in labels {
            
            switch label.delete() {
            case .Success:
                
                MxLog.debug("Label deleted: \(label)")
                
            case let .Failure(error):
                
                let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
                MxStateManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
                
            }
        }
        
    }
    
    func fetchRemoteData( mailbox mailbox: MxMailboxModel){
        
        MxLog.debug("\(#function): processing full fetch of remote data of mailbox: \(mailbox.email)")
        
        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
        
        for mailbox in MxSyncManager.allMailboxes() {
            mailbox.proxy.fetchLabels()
        }
        
        
        // fetch messages in INBOX
//        MxLog.debug("Fetching messages in INBOX for mailbox: \(mailbox.email)")
//        
//        proxies[mailboxUID]!.fetchMessagesInLabel(labelId: MxLabelModel.Id(value: "INBOX"))
        
    
        //
        //        // sync messages of system labels
        //        let labels = localStore.fetchLabels(mailboxId: mailboxId)
        //
        //        for label in labels {
        //            if( label.type == MxLabelModel.OwnerType.SYSTEM){
        //                proxies[mailboxId]!.fetchMessagesInLabel(labelId: label.id)
        //            }
        //        }
        
    }
    
    func remoteDataHasArrived( mailbox mailbox: MxMailboxModel, payload: [MxModelType], error: MxProxyError?){
        
        MxLog.info("\(#function): receiving remote data from mailbox \(mailbox.email)")
        
        switch payload.dynamicType {
        case is [MxLabelModel]:
            
            MxLog.debug(payload.debugDescription)
            
        case is [MxMessageModel]:
            
            MxLog.debug(payload.debugDescription)
            
        default:
            
            MxLog.error("Unidentified payload: \(payload.debugDescription)")
            
        }
    }
    
    
}