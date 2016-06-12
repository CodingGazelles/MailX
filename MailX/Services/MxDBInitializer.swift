//
//  MxDBInitializer.swift
//  MailX
//
//  Created by Tancrède on 5/30/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxDBInitializer {
    
    private static let stack = MxDataStackManager.sharedInstance()
    
    static func insertDefaultProviders(){
        
        guard MxUserPreferences.sharedPreferences().defaultProvidersInserted == false else {
            MxLog.debug("Defaults providers already inserted")
            return
        }
        
        MxLog.debug("Inserting defaults providers")
        
        let appProperties = MxAppProperties.defaultProperties()
        let providers = appProperties.providers()
        
        for providerCode in providers.keys {
            
            var provider = MxProviderModel()
            provider.id = MxObjectId()
            provider.code = providerCode
            provider.name = ""
            
            MxLog.debug("Inserting \(provider)")
            
            stack.setObject(object: provider)
            
        }
        
        MxUserPreferences.sharedPreferences().defaultProvidersInserted = true
    }
    
    static func insertTestMailbox(){
        
        guard MxUserPreferences.sharedPreferences().testMailboxInserted == false else {
            MxLog.debug("Test mailbox already inserted")
            return
        }
        
        MxLog.debug("Inserting default mailboxes")
        
        let email = "mailxtest10@gmail.com"
        let name = "TestMailbox"
        let providerCode = "GMAIL"
        
        let appProperties = MxAppProperties.defaultProperties()
        let providers = appProperties.providers()
        
        var mailbox = MxMailboxModel()
        mailbox.id = MxObjectId()
        mailbox.email = email
        mailbox.name = name
        mailbox.connected = false
        
        MxLog.debug("Inserting \(mailbox)")
        
        stack.setObject(object: mailbox)
        
//        let labels = (providers[providerCode]![MxAppProperties.k_Provider_Labels] as! [String:String]).keys
//        
//        for labelCode in labels {
//            
//            let labelName = appProperties.systemLabels().labelName( labelCode: labelCode)
//            
//            var label = MxLabelModel()
//            label.id = MxObjectId()
//            label.code = labelCode
//            label.name = labelName
//            label.ownerType = MxLabelOwnerType.SYSTEM.rawValue
//            
//            MxLog.debug("Inserting \(label)")
//            
//            stack.setObject(object: label)
//            
//        }
        
        MxUserPreferences.sharedPreferences().testMailboxInserted = true
    }
}
