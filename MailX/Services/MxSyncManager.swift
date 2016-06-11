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
    
    private let store = MxStateManager.defaultStore()
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
        
        let _: Future<[MxMailboxModel],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailboxModel) -> MxMailboxModel in
                        
                        MxLog.debug("Connecting to remote mailbox \(mailbox.email)")
                        
                        mailbox.proxy = MxMailboxProxy( mailbox: mailbox)
                        mailbox.proxy.connect()

                        return mailbox
                        
                }
                
            }
            
            .onFailure { error in
                
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
        
        let _: Future<[MxMailboxModel],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailboxModel) -> MxMailboxModel in
                        
                        self.runFullUpdate(mailbox: mailbox)
                        return mailbox

                }
                
            }
            
            .onFailure { error in
                
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
//        fetchRemoteData(mailbox: mailbox)
        
    }
    
    
    private func emptyLocalData( mailbox mailbox: MxMailboxModel) {
        
        MxLog.debug("Executing full delete of local data of mailbox: \(mailbox.email)")
        
        let labels = mailbox.labels
        
        MxLog.debug("Deleting messages of mailbox: \(mailbox.email)")
        
        for label in labels {
            
            for message in label.messages {
                
                let _: Future<MxMessageModel,MxStackError> = stack.removeObject(id: message.id)
                
                    .onSuccess { value in
                        
                        let desc = message.description
                        MxLog.debug("Message deleted: \(desc)")
                        
                }
                
                    .onFailure { error in
                        
                        let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
                        self.store.dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
                        
                }
                
            }
        }
        
        MxLog.debug("Deleting labels of mailbox: \(mailbox.email)")
        
        for label in labels {
            
            let _: Future<MxLabelModel,MxStackError> = stack.removeObject(id: label.id)
                
                .onSuccess { value in
                    
                    let desc = label.description
                    MxLog.debug("Label deleted: \(desc)")
                    
                }
                
                .onFailure { error in
                    
                    let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
                    self.store.dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
                    
            }
            
        }
        
    }
//    
//    private func fetchRemoteData( mailbox mailbox: MxMailboxModel){
//        
//        MxLog.debug("Executing full fetch of remote data of mailbox: \(mailbox.email)")
//        
//        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
//        
//        for mailbox in MxSyncManager.allMailboxes() {
//            mailbox.proxy.fetchLabels()
//        }
//        
//        
//
//        
//    }
    

    
    
}