//
//  MxNetworkManager.swift
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
    private let stack = MxDataStackManager.defaultStack()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> MxSyncManager in
        return MxSyncManager()
    }()
    
    static func defaultManager() -> MxSyncManager {
        return sharedInstance
    }
    
    
    private init(){}
    
    
    func connectMailboxes() {
        
        MxLog.debug("Connecting to mailboxes")
        
        let _: Future<[MxMailbox],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailbox) -> MxMailbox in
                        
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
        
        let _: Future<[MxMailbox],MxStackError> = stack.getAllObjects()
            
            .onSuccess { results in
                
                let _ = results
                    .map{ (mailbox: MxMailbox) -> MxMailbox in
                        
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
    
    
    func refreshMailbox( mailbox mailbox: MxMailbox) {
        
        MxLog.debug("Refreshing mailbox \(mailbox.email)")
        
        refreshLabelsOfMailbox(mailbox: mailbox)
            
            .onSuccess { _ in
                
                MxLog.debug("Refreshing labels successfull \(mailbox.email)")
                
                dispatchSetLabelsAction()
                
                self.refreshMessagesOfMailbox(mailbox: mailbox)
                    
                    .onSuccess { _ in
                        
                        MxLog.debug("Refreshing messages successfull \(mailbox.email)")
                        
                        dispatchSetMessagesAction()
                    
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
    
    
    func refreshLabelsOfMailbox( mailbox mailbox: MxMailbox) -> Future<MxMailbox, MxNetworkError> {
        
        MxLog.debug("Refreshing labels of mailbox \(mailbox.email)")
        
        // 1 Fetch labels
        fetchLabelsOfMailbox( mailbox: mailbox)
            
            .onSuccess { values in
                
                // 2 Compare with local labels
                let operations: [Operation<MxLabel>] = arrayDiff(
                    modelObjects: Array( mailbox.labels),
                    remoteObjects: values as! [MxLabel])
                
                
                // 3 Update, remove or add labels in local db
                for operation in operations {
                    
                    switch operation.type {
                        
                    case .Delete:
                    case .Insert:
                    case .Noop:
                        
                    }
                    
                }
                
                
                // 4 loop mailbox.labels to fetch messages
                
                for label in mailbox.labels_ {
                    
                }
                
                
            }
            
            .onFailure { error in
                
        }
        
        
        
    }
    
    
    func fetchLabelsOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxCoreLabelProtocol], MxNetworkError> {
        
        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxCoreLabelProtocol], MxNetworkError>()
        
        Queue.global.context {
            
            if mailbox.connected {
                
                mailbox.proxy.fetchLabels()
                
                    .onSuccess { values in
                    
                        MxLog.debug("Did fetch labels of mailbox: \(mailbox.email)")
                        
                        promise.success( values)
                        
                    }
                    
                    .onFailure { error in
                        
                        MxLog.error("Error occurred while fetching labels of mailbox \(mailbox.email)", error: error)
                        
                        let networkError = MxNetworkError.FetchError(
                            message: "Error occurred while fetching labels of mailbox \(mailbox.email)",
                            rootError: error)
                
                        promise.failure( networkError)
                        
                    }
                
            } else {
                
                MxLog.error("Mailbox is not connected \(mailbox.email)", error: nil)
                
                let networkError = MxNetworkError.ConnectError(
                    message: "Mailbox is not connected \(mailbox.email)",
                    rootError: nil)
                
                promise.failure( networkError)
            }
            
        }
        
        return promise.future
        
    }
    
    
    func refreshMessagesOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxMessage], MxNetworkError> {
        
        // 1 Fetch messages
        
        // 2 Compare with local messages
        
        // 3 Update, remove or add messages in local db
        
    }
    
    
    func fetchMessagesOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxMessage], MxNetworkError> {
        
        MxLog.debug("Refreshing messages of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxMessage], MxNetworkError>()
        
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
    //    private func runFullUpdate(mailbox mailbox: MxMailbox){
    //
    //        MxLog.debug("Executing full update of mailbox \(mailbox.email)")
    //
    ////        emptyLocalData(mailbox: mailbox)
    ////        fetchRemoteData(mailbox: mailbox)
    //
    //    }
    
    
    //    private func emptyLocalData( mailbox mailbox: MxMailbox) {
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
    //                let _: Future<MxMessage,MxStackError> = stack.removeObject(id: message.id)
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
    //            let _: Future<MxLabel,MxStackError> = stack.removeObject(id: label.id)
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
    //    private func fetchRemoteData( mailbox mailbox: MxMailbox){
    //        
    //        MxLog.debug("Executing full fetch of remote data of mailbox: \(mailbox.email)")
    //        
    //        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
    //        
    //        for mailbox in MxNetworkManager.allMailboxes() {
    //            mailbox.proxy.fetchLabels()
    //        }
    //        
    //        
    //
    //        
    //    }
    
    
    
    
}