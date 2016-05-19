//
//  MxDataController.swift
//  Reactive Design
//
//  Created by Tancrède on 3/5/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation




class MxDataServices {
    
    private let localStore = MxStoreManager.sharedDb()
    
    
    //MARK: - Get data
    
    func getMailbox( mailboxId mailboxId: MxModelId) -> MxMailboxModel? {
        MxLog.verbose("... Processing. Args: mailboxId= \(mailboxId)")
        
        switch localStore.fetchMailbox(mailboxId: mailboxId) {
        case let .Success(value):
            return value
            
        case let .Failure( error):
            sendErrorNotification( message: "Unable to fetch mailbox with fetchMailbox: \(mailboxId).",error: error)
            return nil
        }
    }
    
    func getMailboxes() -> MxMailboxModelArray {
        MxLog.verbose("... Processing.")
        
        switch localStore.fetchMailboxes() {
        case let .Success(mailboxes):
            return mailboxes
            
        case let .Failure(error):
            sendErrorNotification( message: "Unable to fetch mailboxes.",error: error)
            return MxMailboxModelArray()
        }
    }
    
    func getLabels( mailboxId mailboxId: MxModelId) -> MxLabelModelArray {
        MxLog.verbose("... Processing. Args: mailboxId= \(mailboxId)")
        
        switch localStore.fetchLabels(mailboxId: mailboxId) {
        case let .Success(labels):
            return labels
            
        case let .Failure(error):
            sendErrorNotification( message: "Unable to fetch labels with mailboxId= \(mailboxId)",error: error)
            return MxLabelModelArray()
        }
    }
    
    
    
    
    
    //MARK: - Defaults values
    
    func restoreDefaults(){
        MxLog.verbose("... Processing")
        
        localStore.insertProvider(
            provider: MxProviderModel(
                id: MxModelId( value: "GMAIL")))
        
        localStore.insertMailbox(
            mailbox: MxMailboxModel(
                id: MxModelId(value: "t4ncr3d3@gmail.com"),
                providerId: MxModelId( value: "GMAIL")))
        
        MxLog.verbose("... Done")
    }
    
    
}


// MARK: - Error treatment

func sendErrorNotification( message message: String, error: ErrorType){
    //todo
    
    MxLog.error( "Error: \(error)")
    
    fatalError("Func not implemented")
}
