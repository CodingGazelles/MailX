//
//  MxDBInitializer.swift
//  MailX
//
//  Created by Tancrède on 5/30/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxDBInitializer {
    
    static func insertDefaultProviders(){
        
        guard MxUserPreferences.sharedPreferences().defaultProvidersInserted == false else {
            MxLog.debug("Processing \(#function) defaults providers already inserted")
            return
        }
        
        MxLog.debug("Processing \(#function) inserting defaults providers")
        
        let appProperties = MxAppProperties.defaultProperties()
        let providers = appProperties.providers()
        
        for providerCode in providers.keys {
            
            let provider = MxProviderModel(id: MxObjectId(), code: providerCode)
            provider.insert()
            
        }
        
        MxUserPreferences.sharedPreferences().defaultProvidersInserted = true
    }
    
    static func insertTestMailbox(){
        
        guard MxUserPreferences.sharedPreferences().testMailboxInserted == false else {
            MxLog.debug("Processing \(#function) test mailbox already inserted")
            return
        }
        
        MxLog.debug("\(#function) inserting default mailboxes")
        
        let email = "mailxtest10@gmail.com"
        let name = "TestMailbox"
        let providerCode = "GMAIL"
        
        let appProperties = MxAppProperties.defaultProperties()
        let providers = appProperties.providers()
        
        let mailbox = MxMailboxModel(
            id: MxObjectId()
            , email: email
            , name: name
            , connected: false
            , providerCode: providerCode)
        
        MxLog.debug("Inserting mailbox: \(mailbox)")
        mailbox.insert()
        
        let labels = (providers[providerCode]![MxAppProperties.k_Provider_Labels] as! [String:String]).keys
        
        for labelCode in labels {
            
            let labelName = appProperties.systemLabels().labelName( labelCode: labelCode)
            
            let label = MxLabelModel(
                id: MxObjectId()
                , code: labelCode
                , name: labelName
                , ownerType: MxLabelOwnerType.SYSTEM
                , mailboxId: mailbox.id)
            
            MxLog.debug("Inserting label: \(label)")
            label.insert()
            
        }
        
        MxUserPreferences.sharedPreferences().testMailboxInserted = true
    }
}
