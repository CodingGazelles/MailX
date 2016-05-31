//
//  LabelModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



typealias MxLabelModelResult = Result<MxLabelModel, MxModelError>

final class MxLabelModel: MxModelType, MxLocalPersistable, MxRemotePersistable {
    
    var UID: MxUID
    var remoteId: MxLabelModelId
    var code: String
    var name: String
    var ownerType: MxLabelOwnerType
    var mailboxId: MxMailboxModelId
    
    init(UID: MxUID?
        , remoteId: MxLabelModelId
        , code: String
        , name: String
        , ownerType: MxLabelOwnerType
        , mailboxId: MxMailboxModelId){
        
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.code = code
        self.name = name
        self.ownerType = ownerType
        self.mailboxId = mailboxId
    }
    
    convenience init?( dbo: MxLabelDBO){
        
        guard let ownerType = MxLabelOwnerType( rawValue: dbo.ownerType) else {
            return nil
        }
        
        let remoteId = MxLabelModelId( value: dbo.remoteId)
        let mailboxId = MxMailboxModelId( value: dbo.mailbox!.remoteId)
        
        self.init(
            UID: dbo.UID
            , remoteId: remoteId
            , code: dbo.code
            , name: dbo.name
            , ownerType: ownerType
            , mailboxId: mailboxId)
    }
}

final class MxLabelModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}

func toModel( label label: MxLabelDBO) -> MxLabelModelResult {
    
    guard MxLabelOwnerType( rawValue: label.ownerType) != nil else {
        
        let error =  MxModelError.UnableToConvertDBOToModel(
            dbo: label
            , message: "Unable to instanciate MxLabelOwnerType with MxLabelDBO with args: \(label)"
            , rootError: nil)
        
        return Result.Failure( error)
    }
    
    return Result.Success( MxLabelModel(dbo: label)!)
}


// MARK: - Label Owner Type

enum MxLabelOwnerType: String {
    case SYSTEM = "SYSTEM"
    case USER = "USER"
}
