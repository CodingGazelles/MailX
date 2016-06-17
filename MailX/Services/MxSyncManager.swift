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



class MxSyncManager {
    
    
    // MARK: - Private properties
    
//    private let uiState = MxUIStateManager.defaultStore()
    private let dataStack = MxDataStackManager.defaultStack()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = { () -> MxSyncManager in
        return MxSyncManager()
    }()
    
    static func defaultManager() -> MxSyncManager {
        return sharedInstance
    }
    
    
    private init(){}
    
    /**
     Connect a mailbox
     
     - Important:
     Runs in background thread
     
     
     */
    func connectMailbox( mailbox mailbox: MxMailbox) -> Future<Void, MxSyncError> {
        
        MxLog.debug("Connecting to mailbox \(mailbox.email)")
        
        let promise = Promise<Void, MxSyncError>()
        
        Queue.global.context {
            
            mailbox.proxy = MxMailboxProxy( mailbox: mailbox)
            
            mailbox.proxy.connect()
                
                .onSuccess { _ in
                    
                    mailbox.connected = true
                    MxLog.info("Mailbox is connected \(mailbox)")
                    
                    promise.success()
                    
                }
                
                .onFailure { error in
                    
                    let syncError = MxSyncError.NetworkError(
                        error: MxNetworkError.ConnectError,
                        message: "Error occurred while connecting to mailbox \(mailbox.email)",
                        rootError: error)
                    
                    MxLog.error("Error occurred while connecting to mailbox \(mailbox.email)", error: error)
                    
                    promise.failure(syncError)
                    
            }
            
        }
        
        return promise.future
        
    }
    
    
    /**
     
     - Important
     Needs to run in background
     
     */
    func refreshMailbox( mailbox mailbox: MxMailbox) -> Future<Void, MxSyncError>  {
        
        MxLog.debug("Refreshing mailbox \(mailbox.email)")
        
        let promise = Promise<Void, MxSyncError>()
        
        Queue.global.context {
            
            self.refreshLabelsOfMailbox(mailbox: mailbox)
                
                .onSuccess { _ in
                    
                    MxLog.debug("Refreshing labels successfull \(mailbox.email)")
                    
                    self.refreshMessagesOfMailbox(mailbox: mailbox)
                        
                        .onSuccess { _ in
                            
                            MxLog.debug("Refreshing messages successfull \(mailbox.email)")
                            
                            promise.success()
                            
                        }
                        
                        .onFailure { error in
                            
                            let syncError = MxSyncError.OperationFailed(
                                message: "Error occurred while refreshing messages of mailbox \(mailbox.email)",
                                rootError: error)
                            
                            MxLog.error("Error occurred while refreshing messages of mailbox \(mailbox.email)", error: error)
                            
                            promise.failure(syncError)
                            
                    }
                    
                }
                
                .onFailure { error in
                    
                    let syncError = MxSyncError.OperationFailed(
                        message: "Error occurred while refreshing labels of mailbox \(mailbox.email)",
                        rootError: error)
                    
                    MxLog.error("Error occurred while refreshing labels of mailbox \(mailbox.email)", error: error)
                    
                    promise.failure(syncError)
                    
            }
        }
        
        return promise.future
    }
    
    
    private func refreshLabelsOfMailbox( mailbox mailbox: MxMailbox) -> Future<Void, MxSyncError> {
        
        MxLog.debug("Refreshing labels of mailbox \(mailbox.email)")
        
        let promise = Promise<Void, MxSyncError>()
        
        ImmediateExecutionContext {
            
            // 1 Fetch remote labels
            self.fetchLabelsOfMailbox( mailbox: mailbox)
                
                .onSuccess { values in
                    
                    // 2 Compare with local labels
                    let operations: [Operation] = arrayDiff(
                        managedObjects: Array( mailbox.labels),
                        remoteObjects: values)
                    
                    MxLog.debug("Diff \(operations)")
                    
                    // 3 Update, remove or add labels in local db
                    for operation in operations {
                        
                        switch operation.type {
                            
                        case .Delete:
                            
                            let _ = operation.objects.map { labelToRemove in
                                self.dataStack.removeObject(object: labelToRemove as! MxLabel)
                            }
                            
                        case .Insert:
                            
                            let _ = operation.objects.map { value in
                                
                                let labelToInsert = value as! MxLabelRemote
                                
                                let createdLabel = self.dataStack.createLabel(
                                    internalId: MxInternalId(),
                                    remoteId:  labelToInsert.remoteId!,
                                    code: labelToInsert.code!,
                                    name: labelToInsert.name!,
                                    ownerType: labelToInsert.ownerType,
                                    mailbox: mailbox)
                                
                                mailbox.labels.insert(createdLabel.value!)
                                
                            }
                            
                        case .Noop: /* update */
                            
                            let _ = operation.objects
                                .map { object in
                                    
                                    let label = object as! MxLabel
                                    
                                    let labels = mailbox.labels
                                        .filter { $0.remoteId == label.remoteId }
                                    
                                    guard labels.count == 1 else {
                                        
                                        let error = MxSyncError.UndexpectedError(
                                            object: label,
                                            message: "Label to update can't be found in DB",
                                            rootError: nil)
                                        
                                        MxLog.error("Label to update can't be found in DB \(label)", error: error)
                                        
                                        promise.failure( error)
                                        
                                        return
                                    }
                                    
                                    let labelToUpdate = labels[0]
                                    labelToUpdate.code = label.code
                                    labelToUpdate.name = label.name
                                    labelToUpdate.ownerType = label.ownerType
                                    
                            }
                            
                        }
                        
                    }
                    
                    self.dataStack.saveContext()
                    
                    promise.success()
                    
                }
                
                .onFailure { error in
                    
                    let networkError = MxSyncError.NetworkError(
                        error: MxNetworkError.FetchError,
                        message: "Error occurred while fetching labels of mailbox \(mailbox.email)",
                        rootError: error)
                    
                    promise.failure( networkError)
                    
            }
            
        }
        
        return promise.future
        
    }
    
    
    private func fetchLabelsOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxLabelRemote], MxSyncError> {
        
        MxLog.debug("Fetching labels of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxLabelRemote], MxSyncError>()
        
        ImmediateExecutionContext {
            
            if mailbox.connected {
                
                mailbox.proxy.fetchLabels()
                    
                    .onSuccess { values in
                        
                        MxLog.debug("Did fetch labels of mailbox: \(mailbox.email)")
                        
                        promise.success( values)
                        
                    }
                    
                    .onFailure { error in
                        
                        MxLog.error("Error occurred while fetching labels of mailbox \(mailbox.email)", error: error)
                        
                        let networkError = MxSyncError.NetworkError(
                            error: MxNetworkError.FetchError,
                            message: "Error occurred while fetching labels of mailbox \(mailbox.email)",
                            rootError: error)
                        
                        promise.failure( networkError)
                        
                }
                
            } else {
                
                MxLog.error("Mailbox is not connected \(mailbox.email)", error: nil)
                
                let networkError = MxSyncError.NetworkError(
                    error: MxNetworkError.ConnectError,
                    message: "Mailbox is not connected \(mailbox.email)",
                    rootError: nil)
                
                promise.failure( networkError)
            }
            
        }
        
        return promise.future
        
    }
    
    
    private func refreshMessagesOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxMessage], MxSyncError> {
        
        // 1 Fetch messages
        
        // 2 Compare with local messages
        
        // 3 Update, remove or add messages in local db
        
        MxLog.debug("Refreshing messages of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxMessage], MxSyncError>()
        
        ImmediateExecutionContext {
            
            //TODO: -
            
            promise.success([MxMessage]())
            
        }
        
        return promise.future
        
    }
    
    
    private func fetchMessagesOfMailbox( mailbox mailbox: MxMailbox) -> Future<[MxMessage], MxSyncError> {
        
        MxLog.debug("Fetching messages of mailbox \(mailbox.email)")
        
        let promise = Promise<[MxMessage], MxSyncError>()
        
        ImmediateExecutionContext {
            
            //TODO: -
            
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
    //
    
    
    
    
}