//
//  MxDBInitializer.swift
//  MailX
//
//  Created by Tancrède on 5/30/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxDBInitializer {
    
    static func initializeDB(){
        MxLog.info("Initializing DB.")
        
        insertDefaultProviders()
        insertDefaultMailboxes()
    }
    
    static func insertDefaultProviders(){
        MxLog.debug("Processing \(#function)")
        
        let providers = MxAppProperties.defaultProperties().providers()
        
        for providerCode in providers.keys {
            insertProvider( provider: MxProviderModel(UID: nil, code: providerCode))
        }
    }
    
    static func insertDefaultMailboxes(){
        MxLog.debug("\(#function) inserting default mailboxes")
        
        let mailbox = MxMailboxModel(
            UID: nil
            , remoteId: MxMailboxModelId(value: "")
            , name: "GMail"
            , connected: false
            , providerCode: "GMAIL")
        
        insertMailbox( mailbox: mailbox)
    }
}
