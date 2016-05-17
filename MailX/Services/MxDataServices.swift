//
//  MxDataController.swift
//  Reactive Design
//
//  Created by Tancrède on 3/5/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation




import RxSwift



class MxDataServices {
    
    private let localStore = MxStoreManager.sharedDb()
    
    
    //MARK: - Get data
    
    func getMailbox( mailboxId mailboxId: MxMailbox.Id) -> MxMailbox? {
        MxLog.verbose("... Processing. Args: mailboxId= \(mailboxId)")
        
        switch localStore.fetchMailbox(mailboxId: mailboxId) {
        case let .Success(value):
            return value
            
        case let .Failure( error):
            sendErrorNotification( message: "Unable to fetch mailbox with fetchMailbox: \(mailboxId).",error: error)
            return nil
        }
    }
    
    func getMailboxes() -> MxMailboxes {
        MxLog.verbose("... Processing.")
        
        switch localStore.fetchMailboxes() {
        case let .Success(mailboxes):
            return mailboxes
            
        case let .Failure(error):
            sendErrorNotification( message: "Unable to fetch mailboxes.",error: error)
            return MxMailboxes()
        }
    }
    
    func getLabels( mailboxId mailboxId: MxMailbox.Id) -> MxLabels {
        MxLog.verbose("... Processing. Args: mailboxId= \(mailboxId)")
        
        switch localStore.fetchLabels(mailboxId: mailboxId) {
        case let .Success(labels):
            return labels
            
        case let .Failure(error):
            sendErrorNotification( message: "Unable to fetch labels with mailboxId= \(mailboxId)",error: error)
            return MxLabels()
        }
    }
    
    
    
    
    
    //MARK: - Defaults values
    
    func restoreDefaults(){
        MxLog.verbose("... Processing")
        
        localStore.insertProvider(
            provider: MxProvider(
                id: MxProvider.Id( value: "GMAIL")))
        
        localStore.insertMailbox(
            mailbox: MxMailbox(
                id: MxMailbox.Id(value: "t4ncr3d3@gmail.com"),
                providerId: MxProvider.Id( value: "GMAIL")))
        
        MxLog.verbose("... Done")
    }
    
    
}


    // MARK: - Rx

extension MxDataServices {
    
    
    func rx_getMailboxes() -> Observable<MxMailboxes> {
        return localStore.rx_fetchMailboxes()
    }
    
//    func rx_getLabels(mailboxId mailboxId: MxMailbox.Id) -> Observable<MxLabels> {
//        return localStore.rx_fetchLabels(mailboxId: mailboxId)
//    }
    
    func rx_getLabels() -> Observable<MxLabels> {
        return localStore.rx_fetchLabels()
    }
    
    func rx_getMessages() -> Observable<MxMessages> {
        return localStore.rx_fetchMessages()
    }
    
    
}


// MARK: - Error treatment

func sendErrorNotification( message message: String, error: ErrorType){
    //todo
    
    MxLog.error( "Error: \(error)")
    
    fatalError("Func not implemented")
}
