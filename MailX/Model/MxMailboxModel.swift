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

struct MxMailboxModel: MxModelType {
    
    var UID: MxUID
    var id: MxMailboxModelId
    var name: String
    var connected: Bool
    var providerId: MxProviderModelId
    
    init(UID: MxUID, id: MxMailboxModelId, name: String, connected: Bool, providerId: MxProviderModelId){
        self.init(UID: UID)
        self.id = id
        self.name = name
        self.connected = connected
        self.providerId = providerId
    }
}

struct MxMailboxModelId: MxModelIdType{
    var value: String
}

extension MxMailboxModel: MxInitWithDBO {
    init?( dbo: MxMailboxDBO){
        
        guard dbo.provider != nil else {
            return nil
        }
        
        self.init(   
            UID: dbo.UID
            , id: MxMailboxModelId( value: dbo.id)
            , name: dbo.name
            , connected: false
            , providerId: MxProviderModelId( value: dbo.provider!.id))
    }
}

func toModel( dbo dbo: MxMailboxDBO) -> MxMailboxModelResult {
    
    guard dbo.provider != nil else {
        
        let error =  MxModelError.UnableToConvertDBOToModel(
            dbo: dbo
            , message: "Mailbox without a provider"
            , rootError: nil)
        return Result.Failure( error)
    }
    
    return Result.Success( MxMailboxModel(dbo: dbo)!)
}

