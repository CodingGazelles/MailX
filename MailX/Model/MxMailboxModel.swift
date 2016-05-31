//
//  MxMailboxModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



typealias MxMailboxModelResult = Result<MxMailboxModel, MxModelError>

final class MxMailboxModel: MxModelType, MxLocalPersistable, MxRemotePersistable {
    
    var UID: MxUID
    var remoteId: MxMailboxModelId
    var name: String
    var connected: Bool
    var providerCode: String
    
    init(UID: MxUID?, remoteId: MxMailboxModelId, name: String, connected: Bool, providerCode: String){
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.name = name
        self.connected = connected
        self.providerCode = providerCode
    }
    
    convenience init?( dbo: MxMailboxDBO){
        
        guard dbo.provider != nil else {
            return nil
        }
        
        self.init(
            UID: dbo.UID
            , remoteId: MxMailboxModelId( value: dbo.remoteId)
            , name: dbo.name
            , connected: false
            , providerCode: dbo.provider!.code)
    }
}

final class MxMailboxModelId: MxRemoteId{
    var value: String
    init( value: String){
        self.value = value
    }
}

func toModel( mailbox mailbox: MxMailboxDBO) -> MxMailboxModelResult {
    
    guard mailbox.provider != nil else {
        
        let error =  MxModelError.UnableToConvertDBOToModel(
            dbo: mailbox
            , message: "Mailbox without a provider"
            , rootError: nil)
        return Result.Failure( error)
    }
    
    return Result.Success( MxMailboxModel(dbo: mailbox)!)
}

