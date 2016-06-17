//
//  MxDBInitializer.swift
//  MailX
//
//  Created by Tancrède on 5/30/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



class MxDBInitializer {
    
    private static let stack = MxDataStackManager.defaultStack()
    
    static func insertDefaultProviders() -> Result<[MxProvider], MxStackError> {
        
        guard MxUserPreferences.sharedPreferences().defaultProvidersInserted == false else {
            
            let error = MxStackError.InsertFailed(
                object: nil,
                typeName: "MxProvider" ,
                message: "Defaults providers already inserted",
                rootError: nil)
            
            MxLog.debug("Defaults providers already inserted")
            
            return .Failure( error)
        }
        
        MxLog.debug("Inserting defaults providers")
        
        let appProperties = MxAppProperties.defaultProperties()
        let providers = appProperties.providers()
        var results = [MxProvider]()
        
        for providerCode in providers.keys {
            
            let name = providers[providerCode]![MxAppProperties.k_Provider_Name] as! String
            
            let result = stack.createProvider(
                internalId: MxInternalId( value: providerCode),
                code: providerCode,
                name: name)
            
            MxLog.debug("Inserting \(result.value )")
            results.append(result.value!)
            
        }
        
        MxUserPreferences.sharedPreferences().defaultProvidersInserted = true
        
        return .Success(results)
    }
    
    static func insertTestMailbox( provider provider: MxProvider) -> Result<MxMailbox, MxStackError> {
        
        guard MxUserPreferences.sharedPreferences().testMailboxInserted == false else {
            
            let error = MxStackError.InsertFailed(
                object: nil,
                typeName: "MxMailbox" ,
                message: "Test mailbox already inserted",
                rootError: nil)
            
            MxLog.debug("Test mailbox already inserted")
            
            return .Failure(error)
        }
        
        MxLog.debug("Inserting default mailboxes")
        
        let email = "mailxtest10@gmail.com"
        let name = "TestMailbox"
        
        let result = stack.createMailbox(
            internalId: MxInternalId( value: "TEST_MAILBOX"),
            remoteId: MxRemoteId(value: "TEST_MAILBOX" ),
            email: email,
            name: name,
            provider: provider)
        
        MxLog.debug("Inserting \(result.value )")
        
//        let labels = (providers[providerCode]![MxAppProperties.k_Provider_Labels] as! [String:String]).keys
//        
//        for labelCode in labels {
//            
//            let labelName = appProperties.systemLabels().labelName( labelCode: labelCode)
//            
//            var label = MxLabel()
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
        
        return .Success(result.value!)
    }
}
