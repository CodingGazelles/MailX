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



//enum MxSyncError: MxExceptionProtocol {
//    case PersistenceManagerIsNil(rootError: MxExceptionProtocol? )
//    case SyncManagerIsNil(rootError: MxExceptionProtocol?)
//    case UnableToRealizeDBOperation(rootError: MxExceptionProtocol?)
//    case UnableToRealizeModelOperation(rootError: MxExceptionProtocol?)
//}

class MxSyncManager {
    
    
    // MARK: - Private properties
    
    private let state = MxUIStateManager.defaultStore()
    private let stack = MxDataStackManager.sharedInstance()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> MxSyncManager in
        let syncManager = MxSyncManager()
        return syncManager
    }()
    
    static func defaultManager() -> MxSyncManager {
        return sharedInstance
    }
    
    
    private init(){}
    
    
    func connectMailboxes() {
        
        MxLog.debug("Connecting to mailboxes")
        
        let _: Future<[MxMailboxModel],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailboxModel) -> MxMailboxModel in
                        
                        MxLog.debug("Connecting to mailbox \(mailbox.email)")
                        
                        mailbox.proxy = MxMailboxProxy( mailbox: mailbox)
                        
                        mailbox.proxy.connect()
                            .onSuccess { _ in
                                
                                mailbox.connected = true
                                MxLog.info("Mailbox is connected \(mailbox)")
                                
                            }
                            .onFailure { error in
                                
                                MxLog.error("Error occurred while connecting to mailbox \(mailbox.email)", error: error)
                                
                                let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                                
                                MxLog.debug("Dispatching action: \(action)")
                                
                                let store = MxUIStateManager.defaultStore()
                                store.dispatch(action)
                                
                        }
                        
                        return mailbox
                        
                }
                
            }
            
            .onFailure { error in
                
                MxLog.error("Error occurred while loading all mailboxes", error: error)
                
                let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                
                MxLog.debug("Dispatching action: \(action)")
                
                let store = MxUIStateManager.defaultStore()
                store.dispatch(action)
                
        }
        
    }
    
    
    //MARK: - Update local store with remote data
    
    func refreshAllMailboxes(){
        
        MxLog.debug("Refresh all mailboxes ")
        
        let _: Future<[MxMailboxModel],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailboxModel) -> MxMailboxModel in
                        
                        self.refreshMailbox( mailbox: mailbox)
                        
                        return mailbox
                        
                }
                
            }
            
            .onFailure { error in
                
                MxLog.error("Error occurred while loading all mailboxes", error: error)
                
                let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                
                MxLog.debug("Dispatching action: \(action)")
                
                let store = MxUIStateManager.defaultStore()
                store.dispatch(action)
                
        }
        
    }
    
    
    func refreshMailbox( mailbox mailbox: MxMailboxModel) {
        
        MxLog.debug("Refreshing mailbox \(mailbox.email)")
        
        refreshLabelsOfMailbox(mailbox: mailbox)
            
            .onSuccess { _ in
                
                dispatchSetLabelsAction()
                
                refreshMessagesOfMailbox(mailbox: mailbox)
                    
                    .onSuccess {
                        
                        
                    
                    }
                    
                    .onFailure { error in
                        
                        MxLog.error("Error occurred while refreshing messages of mailbox \(mailbox.email)", error: error)
                        
                        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                        
                        MxLog.debug("Dispatching action: \(action)")
                        
                        let store = MxUIStateManager.defaultStore()
                        store.dispatch(action)
                        
                    }
                
            }
            
            .onFailure { error in
                
                MxLog.error("Error occurred while refreshing labels of mailbox \(mailbox.email)", error: error)
                
                let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                
                MxLog.debug("Dispatching action: \(action)")
                
                let store = MxUIStateManager.defaultStore()
                store.dispatch(action)
                
            }
    }
    
    
    func refreshLabelsOfMailbox( mailbox mailbox: MxMailboxModel) -> Future<MxMailboxModel, MxNetworkError> {
        
        MxLog.debug("Refreshing labels of mailbox \(mailbox.email)")
        
        // 1 Fetch labels
        fetchLabelsOfMailbox( mailbox: mailbox)
            
            .onSuccess { values in
                
                // 2 Compare with local labels
                compare fetched values with local mailbox.labels
                
                
                // 3 Update, remove or add labels in local db
                
                
                // 4 loop mailbox.labels to fetch messages
                
                for label in mailbox.labels {
                    
                }
                
                
            }
            
            .onFailure { error in
                
        }
        
        
        
    }
    
    
    func fetchLabelsOfMailbox( mailbox mailbox: MxMailboxModel) -> Future<[MxLabelModel], MxNetworkError> {
        
        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxLabelModel], MxNetworkError>()
        
        Queue.global.context {
            
            
            
        }
        
        return promise.future
        
    }
    
    
    func refreshMessagesOfMailbox( mailbox mailbox: MxMailboxModel) -> Future<[MxMessageModel], MxNetworkError> {
        
        // 1 Fetch messages
        
        // 2 Compare with local messages
        
        // 3 Update, remove or add messages in local db
        
    }
    
    
    func fetchMessagesOfMailbox( mailbox mailbox: MxMailboxModel) -> Future<[MxMessageModel], MxNetworkError> {
        
        MxLog.debug("Refreshing messages of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxMessageModel], MxNetworkError>()
        
        Queue.global.context {
            
            
            
        }
        
        return promise.future
        
    }
    
    
    //    private func runIncrementalUpdate( mailboxId mailboxId: MxObjectId){
    //
    //        MxLog.debug("Doing incremental update of mailbox: \(mailboxId)")
    //
    //        fatalError("Func not implemented")
    //    }
    //
    //
    //    private func runFullUpdate(mailbox mailbox: MxMailboxModel){
    //
    //        MxLog.debug("Executing full update of mailbox \(mailbox.email)")
    //
    ////        emptyLocalData(mailbox: mailbox)
    ////        fetchRemoteData(mailbox: mailbox)
    //
    //    }
    
    
    //    private func emptyLocalData( mailbox mailbox: MxMailboxModel) {
    //
    //        MxLog.debug("Executing full delete of local data of mailbox: \(mailbox.email)")
    //
    //        let labels = mailbox.labels
    //
    //        MxLog.debug("Deleting messages of mailbox: \(mailbox.email)")
    //
    //        for label in labels {
    //
    //            for message in label.messages {
    //
    //                let _: Future<MxMessageModel,MxStackError> = stack.removeObject(id: message.id)
    //
    //                    .onSuccess { value in
    //
    //                        let desc = message.description
    //                        MxLog.debug("Message deleted: \(desc)")
    //
    //                }
    //
    //                    .onFailure { error in
    //
    //                        let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
    //                        self.store.dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
    //
    //                }
    //
    //            }
    //        }
    //
    //        MxLog.debug("Deleting labels of mailbox: \(mailbox.email)")
    //
    //        for label in labels {
    //
    //            let _: Future<MxLabelModel,MxStackError> = stack.removeObject(id: label.id)
    //
    //                .onSuccess { value in
    //
    //                    let desc = label.description
    //                    MxLog.debug("Label deleted: \(desc)")
    //
    //                }
    //
    //                .onFailure { error in
    //
    //                    let error = MxSyncError.UnableToRealizeDBOperation(rootError: error)
    //                    self.store.dispatch( MxAddErrorsAction( errors: [MxErrorSO( error: error )]))
    //
    //            }
    //
    //        }
    //
    //    }
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