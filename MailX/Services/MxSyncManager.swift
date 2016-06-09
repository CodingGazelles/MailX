//
//  MxSyncManager.swift
//  Hexmail
//
//  Created by Tancrède on 4/2/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import Result
import BrightFutures



enum MxSyncError: MxExceptionProtocol {
    case PersistenceManagerIsNil(rootError: MxExceptionProtocol? )
    case SyncManagerIsNil(rootError: MxExceptionProtocol?)
    case UnableToRealizeDBOperation(rootError: MxExceptionProtocol?)
    case UnableToRealizeModelOperation(rootError: MxExceptionProtocol?)
}

class MxSyncManager {
    
    
    // MARK: - Private properties
    
    private let store = MxStoreManager.defaultStore()
    private let stack = MxStackManager.sharedInstance()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> MxSyncManager in
        let syncManager = MxSyncManager()
        return syncManager
    }()
    
    static func defaultManager() -> MxSyncManager {
        return sharedInstance
    }
    
    
    private init(){}
    
    
    //MARK: - Synchronize local mailboxes with remote store
    
    func startSynchronization(){
        
        connectMailboxes()
        
        updateMailboxes()
        
        startSync()
        
    }
    
    private func connectMailboxes() {
        
        MxLog.debug("Connecting to remote mailboxes")
        
        let _: Future<[Result<MxMailboxModel,MxStackError>],MxStackError> = stack.getAllObjects()
            
            .onSuccess(Queue.main.context) { results in
                
                results
                    .filter{ $0.value != nil }
                    .map{
                        
                        let mailbox = $0.value
                        let proxy = MxMailboxProxy( mailbox: mailbox!)
                        
                        mailbox!.proxy = proxy
                        
                        MxLog.debug("Connecting to remote mailbox \(mailbox!.email)")
                        
                        proxy.connect()
                        
                }
                
            }
            
            .onFailure(Queue.main.context) { error in
                
                MxLog.error("Error while loading all mailboxes")
                
            }
        
    }
    
    private func startSync() {
        
        MxLog.debug("Starting synchronization (initiating pulling data from providers)")
        
        //todo
        
    }
    
    
    //MARK: - Update local store with remote data
    
    private func updateMailboxes(){
        
        MxLog.debug("Updating all mailboxes ")
        
        let _: Future<[Result<MxMailboxModel,MxStackError>],MxStackError> = stack.getAllObjects()
            
            .onSuccess(Queue.main.context) { results in
                
                results
                    .filter{ $0.value != nil }
                    .map{
                        
                        
                        let mailbox = $0.value
                        self.runFullUpdate(mailbox: mailbox!)
                        
                }
                
            }
            
            .onFailure(Queue.main.context) { error in
                
                MxLog.error("Error while loading all mailboxes")
                
        }
        
    }
    
    
    private func runIncrementalUpdate( mailboxId mailboxId: MxObjectId){
        
        MxLog.debug("Doing incremental update of mailbox: \(mailboxId)")
        
        fatalError("Func not implemented")
    }
    
    
    private func runFullUpdate(mailbox mailbox: MxMailboxModel){
        
        MxLog.debug("Executing full update of mailbox \(mailbox.email)")
        
        emptyLocalData(mailbox: mailbox)
        
        fetchRemoteData(mailbox: mailbox)
        
    }
    
    
    private func emptyLocalData( mailbox mailbox: MxMailboxModel) {
        
        MxLog.debug("Executing full delete of local data of mailbox: \(mailbox.email)")
        
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
                    MxStoreManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxSOError( error: error )]))
                    
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
                MxStoreManager.defaultManager().dispatch( MxAddErrorsAction( errors: [MxSOError( error: error )]))
                
            }
        }
        
    }
    
    private func fetchRemoteData( mailbox mailbox: MxMailboxModel){
        
        MxLog.debug("Executing full fetch of remote data of mailbox: \(mailbox.email)")
        
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
    
    func remoteDataHasArrived( mailbox mailbox: MxMailboxModel, payload: [MxModelObjectProtocol], error: MxProxyError?){
        
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